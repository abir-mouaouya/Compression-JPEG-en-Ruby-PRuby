#!/usr/bin/env ruby

require 'cmath'
require 'pruby'

N = 8
K = 1
Q = Array.new(N){Array.new(N)}

# Initialisation de la matrice DCT arrondie
matrice_dct = [[649,93,-290,-51,71,-13,15,20], [187,50,-181,-20,34,-15,15,6],
			   [-69,-20,84,32,-43,-2,2,-13], [-173,-26,141,13,-42,6,-13,-14],
			   [-32,4,24,-3,4,10,0,-3], [38,4,-29,2,-2,-10,-5,0], [-30,-5,53,15,-4,19,-7,-5],
			   [-15,0,32,9,-14,9,-7,-14]]

#matrice_dct = [[649,93,-290,-51,71,-13,15,20],	
#			   [187,50,-181,-20,34,-27,15,6],
#			   [-69,-20,84,20,-43,-2,23,-36],
#			   [-173,2,141,13,-42,6,-13,-13],
#			   [-32,-9,24,-3,4,10,-10,-3],
#			   [38,4,-12,-20,-2,-10,-5,0],
#			   [-30,-5,53,24,-4,19,-7,-5],
#			   [-15,0,32,9,-14,9,-7,-14]]			   

# calcul de la matrice de quantification en fonction du pas de quantification
def initQuant(k)
	# k est le pas de quantification

	a = Array.new(N){Array.new(N)}
	for i in 0...N
        for j in 0...N
            a[i][j]=1+k*(1+i+j)
        end
    end 
	return a
end

# Calcul de la matrice quantifiée
def quant(dct,q)
	# dct est l'image dct
	# q est la matrice de quantification

	a = Array.new(N){Array.new(N)}

	for i in 0...N
        for j in 0...N
            a[i][j]=dct[i][j] / q[i][j]
        end
    end 
	return a
end

# Définition en mode parallele de la fonction de calcul de la matrice de quantification 
def initQuant_P(k, nb_threads = PRuby.nb_threads)
	a = Array.new(N){Array.new(N)}
	(0...N). peach(nb_threads: nb_threads) do |i|
		(0...N). peach(nb_threads: nb_threads) do |j|
		    a[i][j]=1+k*(1+i+j)  
		end
	end
	return a
end

# Définition en mode parallele de la fonction de calcul de la matrice quantifiée
def quant_P(dct,q,nb_threads = PRuby.nb_threads)
	a = Array.new(N){Array.new(N)}
	(0...N). peach(nb_threads: nb_threads) do |i|
		(0...N). peach(nb_threads: nb_threads) do |j|
		    a[i][j]=dct[i][j] / q[i][j] 
		end
	end
	return a
end

# Fonction d'affichage d'une matrice
def afficher_matrice(a)
	nl = a.size()
	nc = a[0].size()
	for i in 0...nl
		for j in 0...nc
			print a[i][j], "\t"
		end
		print "\n"
	end
end

# Initialisation de la matrice de quantification qui est la matrice standardisée dite de facto
q = [[16,11,10,16,24,40,51,61], [12,12,14,19,26,58,60,55], [14,13,16,24,40,57,69,56],
	 [14,17,22,29,51,87,80,62], [18,22,37,56,68,109,103,77], [24,35,55,64,81,104,113,92],
	 [49,64,78,87,103,121,120,101], [72,92,95,98,112,100,103,99]]

# Exécution séquentielle
temps_debut = Time.now
img_quant = quant(matrice_dct,q)
temps_fin = Time.now
temps_ecoule = temps_fin - temps_debut

print "\n*** Execution sequentielle ***\n"
print "Matrice quantifiee par la matrice de quantification facto : \n"
afficher_matrice(img_quant)
print "Temps ecoule : ", temps_ecoule, " s\n\n"

# Exécution parallèle
temps_debut = Time.now
img_quant = quant_P(matrice_dct, q, PRuby.nb_threads)
temps_fin = Time.now
temps_ecoule = temps_fin - temps_debut

print "\n*** Execution parallele ***\n"
print "Matrice quantifiee par la matrice de quantification facto : \n"
afficher_matrice(img_quant)
print "Temps ecoule : ", temps_ecoule, " s\n\n"