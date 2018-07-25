function [ mIoU,masque_depart,masque_arrive ] = mIoU( image1, image2 )

[nb_lignes, nb_colonnes] = size(image1);

masque_depart = zeros(nb_lignes,nb_colonnes);
masque_arrive = zeros(nb_lignes,nb_colonnes);

[x,y] = find(image1 ~= 0 & image1 ~= 255);
nb_points = length(x);
for point = 1:nb_points
    masque_depart(x(point),y(point)) = 1;
end

[x,y] = find(image2(:,:,1) ~= 0 | image2(:,:,2) ~= 0 | image2(:,:,3) ~= 0);
nb_points = length(x);
for point = 1:nb_points
    masque_arrive(x(point),y(point)) = 1;
end

mIoU =  sum(sum(masque_depart & masque_arrive)) / sum(sum(masque_depart | masque_arrive));

end

