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
% nb_points_erosion : définit la taille de l'érosion
nb_points_erosion = 5;

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

SE = strel('rectangle',[nb_points_erosion nb_points_erosion]);

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
    
    for coul = 1:nb_couleurs

        % Etape d'erosion des masques
        erodee = imerode(1-masques(:,:,coul),SE);
        % Phase d'attribution des couleurs au masque final
        pos = find(erodee == 1);
        % Conversion en ligne, colonne
        for p=1:length(pos)
            [l,c] = ind2sub([nb_lignes nb_colonnes],pos(p));
            masque_resultat(l,c,1) = couleurs_masques(1,find(mask_colors == couleurs(coul)))/255;
            masque_resultat(l,c,2) = couleurs_masques(2,find(mask_colors == couleurs(coul)))/255;
            masque_resultat(l,c,3) = couleurs_masques(3,find(mask_colors == couleurs(coul)))/255;
        end
        
    end
    
    %% Enregistrement du nouveau masque
    imwrite(masque_resultat,fullfile(DESTINATION_PATH,nom_n),'png');
end

% Fermeture du descripteur de fichier
fclose(fid);