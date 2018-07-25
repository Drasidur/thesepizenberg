clear;
close all;

VOCdevkit = '/home/julien/Bureau/VOCdevkit/';
SOURCE_PATH = strcat(VOCdevkit,'VOC2012/SegmentationClass/');
DESTINATION_PATH = strcat(VOCdevkit,'VOC2012/SegmentationClassNouveau/');

% list : contient dans une structure les annotations d'apprentissage
list = dir(DESTINATION_PATH);
% n : nombre d'annotations
n = length(list);
nl = 1464;

ms = [];

for i =3:nl
    nom_n = list(i).name;
    Image1 = imread(strcat(SOURCE_PATH,nom_n));
    Image2 = imread(strcat(DESTINATION_PATH,nom_n));
    
    [m, m_d, m_a] = mIoU(Image1, Image2);
    
%     subplot 121
%     imshow(m_d);
%     subplot 122
%     imshow(m_a);
    ms = [ms m];
end

mean(ms)