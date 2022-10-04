#!/usr/bin/env ruby

require 'pruby'

n = 0
p = 0

# Fonction de calcul de la combinaison : méthode séquentielle
def combinaison(n, p)
    if 0 < p and p < n
		return combinaison(n-1,p-1) + combinaison(n-1,p)
    elsif p==0 or p==n
        return 1
	end

    return 0
end

# Fonction de calcul de la combinaison : méthode parallèle
def combinaison_parallele(n, p, nb_threads=PRuby.nb_threads)
	if 0 < p and p < n
		a = nil
		b = nil
		PRuby . pcall lambda { a = combinaison_parallele(n-1,p-1) },
					  lambda { b = combinaison_parallele(n-1,p) }
		return a + b
    elsif p==0 or p==n
        return 1
	end

    return 0
end

# Saisie des entiers n et p
loop do
    print "Entrez deux entiers n et p tels que p <= n : \n"
	print "n = "
	n = gets.chomp.to_i
	print "p = "
	p = gets.chomp.to_i
	if n >= p
		break
	end
end

# Exécution séquentielle
temps_debut = Time.now
a = combinaison(n,p)
temps_fin = Time.now
temps_ecoule = temps_fin - temps_debut

print "\n*** Execution sequentielle ***\n"
print "Le nombre de combinaisons de ", p, " dans ", n, " est : ", a, "\n"
print "Temps ecoule : ", temps_ecoule, " s\n\n"


# Exécution parallèle
temps_debut = Time.now
b = combinaison_parallele(n,p,PRuby.nb_threads)
temps_fin = Time.now
temps_ecoule = temps_fin - temps_debut

print "*** Execution parallele ***\n"
print "Le nombre de combinaisons de ", p, " dans ", n, " est : ", b, "\n"
print "Temps ecoule : ", temps_ecoule, " s\n\n"
