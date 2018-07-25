clear;
close all;

%% Chemin d'acces
VOCdevkit = '/home/julien/Bureau/VOCdevkit/';
SOURCE_PATH = strcat(VOCdevkit,'VOC2012/SegmentationClass/');
DESTINATION_PATH = strcat(VOCdevkit,'VOC2012/SegmentationClassNouveau/');
fid = fopen(strcat(VOCdevkit,'VOC2012/ImageSets/Segmentation/train.txt'));

%% Variables globales

% list : contient dans une structure les annotations d'apprentissage
list = dir(SOURCE_PATH);
% n : nombre d'annotations
n = length(list);
% nl : nombre d'image d'apprentissage
nl = 1464;
% nombre de sommets lors de l'application de la division de skeleton
nb_sommets = 5;

% Couleurs des classes
couleurs_masques = [[192; 128; 128], [128;128;0] , [64; 0; 0],...
    [64; 128;0], [64; 0; 128], [192; 0; 128],...
    [128; 64; 0] , [128; 0; 0] , [0; 128; 0] ,...
    [0; 128; 128] ,[0; 0; 128] ,[128; 128; 128],...
    [64; 128; 128], [128; 192; 0], [128; 0 ; 128],...
    [192; 0; 0], [192; 128; 0], [0; 64; 0],...
    [0; 192; 0], [0; 64; 128]];

% Couleur des contours
bord = [224; 224; 192];

% Table de correspondance entre valeurs du masque et couleur i.e
% Si le masque a un pixel de valeur 17 alors la couleur de ce pixel est 
% couleurs_masques(:,find(mask_colors == 17))
mask_colors = [15, ...
    3, 8, 10, 12, 13, 17, ...
    1, 2, 6, 4, 7, 14, 19, ...
    5, 9, 11, 16, 18, 20];

%% On fait le traitement image par image
for i=3:nl
    %% On recupere les donnees caracterisant l'image
    %  nom_n : le nom de l'image sous la forme XXX.extension
    %  nom_n = list(i).name;
    nom_n = strcat(fscanf(fid, '%s' ,1),'.png');
    %  image : l'image courante
    image = imread(strcat(SOURCE_PATH,nom_n));
    %  les dimensions de l'image
    [nb_lignes,nb_colonnes] = size(image);
    %  masque_resultat : le nouveau masque a calculer
    masque_resultat = zeros(nb_lignes,nb_colonnes,3);
    
    %  couleurs : les indices de couleurs presentes dans l'image
    couleurs = unique(image);
    %  nb_couleurs : nombre de couleurs et donc de classes dans l'image
    nb_couleurs = length(couleurs) - 2;
    %  on enleve le noir et le blanc
    couleurs = couleurs(2:end-1);
    %  On detecte si l'image comporte du gris pour un traitement futur
    gris = ismember(15,couleurs);
    
    %% Construction des masques en noir et blanc pour chaque classe presente
    %  dans l'image
    masques = ones(nb_lignes,nb_colonnes,nb_couleurs);
    for coul=1:nb_couleurs
        [x,y] = find(image == couleurs(coul));
        nb_points = length(x);
        for point = 1:nb_points
            masques(x(point),y(point),coul) = 0;
        end
    end
    
    %% Division et traitement en/par composantes connexes
    %  largeur_annulation_bord : on met a 1 une certainte proportion
    %  des bords pour permettre a div_skeleton de fonctionner correctement
    largeur_annulation_bord = 3;
    for coul = 1:nb_couleurs
        masques(1:end,1:largeur_annulation_bord,coul) = 1;
        masques(1:end,end-largeur_annulation_bord:end,coul) = 1;
        masques(1:largeur_annulation_bord,1:end,coul) = 1;
        masques(end-largeur_annulation_bord:end,1:end,coul) = 1;
        
        % On recupere les contours des objets et on ne garde que ceux qui
        % sont assez grand
        BW = bwboundaries(masques(:,:,coul));
        nb_composantes = length(BW);
        BW_res = [];
        nb_composantes_conservees = 0;
        for comp=1:nb_composantes
            boundary = BW{comp};
            if size(boundary,1) > 10
                nb_composantes_conservees = nb_composantes_conservees + 1;
            end
        end
        
        % composantes : matrice des differentes composantes
        composantes = ones(nb_lignes,nb_colonnes,nb_composantes_conservees);
        num_comp = 0;
        % res : matrice resultat qui contient les codes couleurs aux
        %       nouveaux endroit calcules
        res = zeros(nb_lignes,nb_colonnes);
        for comp=2:nb_composantes
            boundary = BW{comp};
            if size(boundary,1) > 10
                num_comp = num_comp + 1;
                yf = boundary(:,2);
                xf = boundary(:,1);
                nb_points = length(xf);
                % Construction du contour
                for point = 1:nb_points
                    composantes(xf(point),yf(point),num_comp) = 0;
                end
                % Remplissage du contour
                composantes(:,:,num_comp) = imfill(1 - composantes(:,:,num_comp));
                composantes(:,:,num_comp) = 1 - composantes(:,:,num_comp);
                
                % Division de skeleton
                [bw,I0,x,y,x1,y1,aa,bb]=div_skeleton_new(4,1,composantes(:,:,num_comp),nb_sommets);
                
                % Remplissage du resultat - Contour
                for pt=1:length(x)
                    % Remplissage point du contour
                    res(x(pt),y(pt)) = 1;
                    % Calcul des points du contour via l'algo de Bresenham
                    if pt ~= length(x)
                        [xr, yr] = bresenham(x(pt),y(pt),x(pt+1),y(pt+1));
                    else
                        [xr, yr] = bresenham(x(pt),y(pt),x(1),y(1));
                    end
                    % Remplissage du contour
                    for ptc=1:length(xr)
                        res(xr(ptc),yr(ptc)) = 1;
                    end
                end
                
                % Remplissage de l'interieur de la forme
                res =  imfill(res);
            end
        end
        
        %% Phase d'attribution des couleurs au masque final
        pos = find(res == 1);
        % Conversion en ligne, colonne
        for p=1:length(pos)
            [l,c] = ind2sub([nb_lignes nb_colonnes],pos(p));
            masque_resultat(l,c,1) = couleurs_masques(1,find(mask_colors == couleurs(coul)))/255;
            masque_resultat(l,c,2) = couleurs_masques(2,find(mask_colors == couleurs(coul)))/255;
            masque_resultat(l,c,3) = couleurs_masques(3,find(mask_colors == couleurs(coul)))/255;
        end
        
        %% Ajout d'un bord - FACULTATIF
        
    end
    %% Enregistrement du nouveau masque
    imwrite(masque_resultat,fullfile(DESTINATION_PATH,nom_n),'png');
end

% Fermeture du descripteur de fichier
fclose(fid);