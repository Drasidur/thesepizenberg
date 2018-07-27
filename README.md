# thesepizenberg
Travail réalisé pendant mon stage au laboratoire IRIT - Toulouse

Les fichiers build_env.sh, code.py test.sh et Tutoriel_Osirim sont ici pour présenter le fonctionnement du cluster Osirim.

Le dossier DeepLab contient les résultats des exécutions de l'apprentissage sur des bases dégradées.

Le dossier Degradation contient les méthodes de dégradation des bases.

Lien vers DeepLab : https://github.com/tensorflow/models
Lien vers PSPNET : https://github.com/zijundeng/pytorch-semantic-segmentation

Penser à générer les tfrecords en local et à les envoyer sur Osirim avant les calculs.
Penser à supprimer les trains (exp/.../trains) pour ne pas fausser les calculs dans l'apprentissage.
