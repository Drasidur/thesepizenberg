function nb_pixel = longueur_frontiere( x,y )

nb_pixel = 0;

taille = length(x);

for i = 1:taille-1
    nb_pixel = nb_pixel + sqrt((x(i)-x(i+1))^2 + (y(i)-y(i+1))^2);
end

nb_pixel = floor(nb_pixel);

end

