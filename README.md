A collection of simple scripts to manage a video collection
===========================================================

allocine-rename.sh
------------------

Script de normalisation des noms de films basé sur allocine.

2 modes :

* auto : devine l'id allocine si le fichier est nommé avec acxxxxx
* manuel : l'id allocine doit être passé avec le nom du fichier

organize-by-links.sh
--------------------

Script qui permet de trier les films suivants deux critères :

* par nouveautés (par defaut 60 jours cf variable NEW_DAYS)
* par première lettre du fichier (par défaut créé 10 repertoires cf variable NB_ALPHANUM_DIRS)

