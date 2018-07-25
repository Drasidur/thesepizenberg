SOURCE_PATH = 'C:\Users\julie_000\Desktop\VOCdevkit\VOC2012\SegmentationClass\';
DESTINATION_PATH = 'C:\Users\julie_000\Desktop\VOCdevkit\VOC2012\SegmantationClassBNW';
TEMPO = 'C:\Users\julie_000\Desktop\VOCdevkit\VOC2012\TEMPO\';

% list contient dans une structure les annotations d'apprentissage
list = dir(SOURCE_PATH);
n = length(list);
% nombre de sommets lors de l'application de la division de squelete
nb_sommets = 20;

couleurs_masques = [[192; 128; 128], [128;128;0] , [64; 0; 0],...
    [64; 128;0], [64; 0; 128], [192; 0; 128],...
    [128; 64; 0] , [128; 0; 0] , [0; 128; 0] ,...
    [0; 128; 128] ,[0; 0; 128] ,[128; 128; 128],...
    [64; 128; 128], [128; 192; 0], [128; 0 ; 128],...
    [192; 0; 0], [192; 128; 0], [0; 64; 0],...
    [0; 192; 0], [0; 64; 128]];

bord = [224; 224; 192];

mask_colors = [15, ...
    3, 8, 10, 12, 13, 17, ...
    1, 2, 6, 4, 7, 14, 19, ...
    5, 9, 11, 16, 18, 20];

for i=58:58%n
    
    close all
    
    nom_n = list(i).name;
    image = imread(strcat(SOURCE_PATH,nom_n));
    [nb_lignes,nb_colonnes] = size(image);
    
    couleurs = unique(image);
    nb_couleurs = length(couleurs) - 2;
    couleurs = couleurs(2:end-1);
    gris = ismember(15,couleurs);
    masques = ones(nb_lignes,nb_colonnes,nb_couleurs);
    
    for k=1:nb_lignes
        for l=1:nb_colonnes
            coul = image(k,l);
            if (coul ~= 0 && coul ~= 255)
                pos = find(couleurs == coul);
                masques(k,l,pos) = 0;
            end
        end
    end
    
    for k = 1:nb_couleurs
        couleur = couleurs(k);
        xtot = [];
        ytot = [];
        forme = 1;
        cop = masques(:,:,k);
        while(length(find(masques(:,:,k) == 0 )) ~= 0)
            masques(1:end,1:3,k) = 1;
            masques(1:end,end-3:end,k) = 1;
            masques(1:3,1:end,k) = 1;
            masques(end-3:end,1:end,k) = 1;
            [bw,I0,x,y,x1,y1,aa,bb]=div_skeleton_new(4,1,masques(:,:,k),nb_sommets);
            
            if (length(x) == nb_sommets + 1)
                xtot(forme,:) = x';
                ytot(forme,:) = y';
            else
                x(end:21) = x(1);
                y(end:21) = y(1);
                xtot(forme,:) = x';
                ytot(forme,:) = y';
            end
            
            
            
            if (length(unique(xtot(forme,:))) <=10 || length(unique(ytot(forme,:))) <=10)
                xmin = min(xtot(forme,:));
                xmax = max(xtot(forme,:));
                ymin = min(ytot(forme,:));
                ymax = max(ytot(forme,:));
                
                masques(xmin:xmax,ymin:ymax,k) = 1;
            else
                
            
            BW = bwboundaries(masques(:,:,k));
            boundary = BW{1};
            yf = boundary(:,2);
            xf = boundary(:,1);

            %if ~(masques(xf(1),yf(1)) == 1)
            
            %plot(yf,xf,'b');
            [in_tmp,on_tmp] = inpolygon(yf,xf,ytot(forme,:),xtot(forme,:));
            sum(in_tmp) + sum(on_tmp);
            
            cont = 1;
            %%
            perc_rouge = 4;
            if (i == 8 || i == 20 || i == 44)
                perc_rouge = 2;
            elseif (i == 37 || i == 54)
                perc_rouge = 8;
            end
            %%
            while((sum(in_tmp) + sum(on_tmp) < (longueur_frontiere(xtot(forme,:),ytot(forme,:))/perc_rouge)))
                boundary = BW{cont + 1};
                yf = boundary(:,2);
                xf = boundary(:,1);
                cont = cont + 1;
                [in_tmp,on_tmp] = inpolygon(yf,xf,ytot(forme,:),xtot(forme,:));
            end
            
            % indEnv = convhull(xtot(forme,:),ytot(forme,:));
            if (length(any(xf)) == 1 || length(any(yf)) == 1)
                masques(xf,yf,k) = 1;
            else
                
                indEnv = convhull(xf,yf);
                xv = xf(indEnv)';
                yv = yf(indEnv)';
                % xv = xtot(forme,indEnv)';
                % yv = ytot(forme,indEnv)';
                % maximum = max(nb_colonnes,nb_lignes);
                pas = 1/nb_lignes;
                xq = floor(1:pas:nb_colonnes + 1 - pas)';
                yq = repmat([1:nb_lignes]',nb_colonnes,1);
                [in,on] = inpolygon(xq,yq,yv,xv);
                % [l,c] = ind2sub([nb_colonnes nb_lignes],find(in ~= 0));
                
                prof = 6;
                for pos = 1:nb_lignes*nb_colonnes
                    if (in(pos) == 1 || on(pos) == 1)
                        [l,c] = ind2sub([nb_lignes nb_colonnes],pos);
                        masques(l,c,k) = 1;
                    end
                    if (on(pos) == 1)
                        [l,c] = ind2sub([nb_lignes nb_colonnes],pos);
                        
                        %                     xmin = max(l - prof,1);
                        %                     xmax = min(l + prof, nb_lignes);
                        %                     ymin = max(c - prof,1);
                        %                     ymax = min(c + prof, nb_colonnes);
                        %                     masques(xmin:xmax,ymin:ymax,k) = 1;
                    end
                end
            end
            %end
            end
            forme = forme + 1;
        end
        
        for ligne=1:nb_lignes
            for colonne=1:nb_colonnes
                if cop(ligne,colonne) == 255
                    cop(ligne,colonne) = 0;
                end
            end
        end 
        imshow(cop);
        
        set(gcf, 'PaperPositionMode', 'auto');
        
        for k=1:size(xtot,1)
            hold on;
            plot(ytot(k,:), xtot(k,:), '-g');
            fill(ytot(k,:),xtot(k,:),couleurs_masques(:,find(mask_colors == couleur))'/255);
        end
        
        filename = strcat(nom_n, '_');
        filename = strcat(filename,int2str(couleur));
        filename = strcat(filename,'.png');
        
        f=getframe(gca);
        X =frame2im(f);
        imwrite(X,fullfile(TEMPO,filename),'png')
        % set(gcf,'Position',[100 100 nb_colonnes-100 nb_lignes])
        % saveas(gcf,fullfile(TEMPO,filename))
        % print(gcf, '-djpeg', fullfile(TEMPO,filename));
    end
    
    list_tmp = dir(strcat(TEMPO,'/',nom_n,'*'));
    res = [];
    for tmp=1:length(list_tmp)
        nom = list_tmp(tmp).name;
        m = imread(strcat(TEMPO,nom));
        [nb_lignes_tmp,nb_colonnes_tmp,~] = size(m);
        for lig=1:nb_lignes_tmp
            for col=1:nb_colonnes_tmp
                if (m(lig,col,1) > 240 && m(lig,col,2) > 240 && m(lig,col,3) > 240 ...
                 || m(lig,col,1) == m(lig,col,2) && m(lig,col,2) == m(lig,col,3))
                    if (m(lig,col,1) ~= 128 || ~gris)
                        m(lig,col,:) = 0;
                    end
                else 
                    a = strsplit(nom,'_');
                    b = a(3);
                    b = b{1};
                    b = strsplit(b,'.');
                    b = str2num(b{1});
                    m(lig,col,1) = couleurs_masques(1,find(mask_colors == b));
                    m(lig,col,2) = couleurs_masques(2,find(mask_colors == b));
                    m(lig,col,3) = couleurs_masques(3,find(mask_colors == b));
                end
            end
        end
        if tmp == 1
            res = m;
        else
            for lignec=1:nb_lignes_tmp
                for colonnec=1:nb_colonnes_tmp
                    if (res(lignec,colonnec,1) == 0 && res(lignec,colonnec,2) == 0 && res(lignec,colonnec,3) == 0)
                        res(lignec,colonnec,1) = m(lignec,colonnec,1);
                        res(lignec,colonnec,2) = m(lignec,colonnec,2);
                        res(lignec,colonnec,3) = m(lignec,colonnec,3);
                    end
                end
            end
            %res = res + m;
        end
    end
    
    profondeur = 4;
    res_cop = res;
    for lig=1:nb_lignes_tmp
        for col=1:nb_colonnes_tmp
            if (res(lig,col,1) ~= 0 || res(lig,col,2) ~= 0 || res(lig,col,3) ~= 0)
                for sub=1:profondeur
                    ls = max(1,lig-sub);
                    lsp = min(nb_lignes_tmp,lig+sub);
                    cs = max(1,col-sub);
                    csp = min(nb_colonnes_tmp,col+sub);
                    if (res(ls,col,1) == 0 && res(ls,col,2) == 0 && res(ls,col,3) == 0)
                        res_cop(ls,col,1) = bord(1);
                        res_cop(ls,col,2) = bord(2);
                        res_cop(ls,col,3) = bord(3);
                    end
                    if (res(lsp,col,1) == 0 && res(lsp,col,2) == 0 && res(lsp,col,3) == 0)
                        res_cop(lsp,col,1) = bord(1);
                        res_cop(lsp,col,2) = bord(2);
                        res_cop(lsp,col,3) = bord(3);
                    end
                    if (res(lig,cs,1) == 0 && res(lig,cs,2) == 0 && res(lig,cs,3) == 0)
                        res_cop(lig,cs,1) = bord(1);
                        res_cop(lig,cs,2) = bord(2);
                        res_cop(lig,cs,3) = bord(3);
                    end
                    if (res(lig,csp,1) == 0 && res(lig,csp,2) == 0 && res(lig,csp,3) == 0)
                        res_cop(lig,csp,1) = bord(1);
                        res_cop(lig,csp,2) = bord(2);
                        res_cop(lig,csp,3) = bord(3);
                    end
                end
            end
        end
    end

    imwrite(res_cop,fullfile(DESTINATION_PATH,nom_n),'png')
end