require'pruby'

#****************la fonction parallele**********************

def fact_parallele(n)
   (1..n).preduce(1,nb_threads: PRuby.nb_threads) do |prod, k|
           prod*k
   end  
end

#****************la fonction sequentiel**********************

def fact_recursive(n)
   if n==1
      return n
   else
      return n*fact_recursive(n-1)
   end
end

def fact_sequentiel(n)
     f=1
     for i in 1..n
        f=f*i
     end
     f
end

puts "entrer un nombre-->"
n=gets.chomp.to_i

#**********le calcul du temps d'execution*************
deb_para=Time.now
  f_para=fact_parallele(n)
fin_para=Time.now

deb_rec=Time.now
  f_rec=fact_recursive(n)
fin_rec=Time.now

deb_seq=Time.now
  f_seq=fact_sequentiel(n)
fin_seq=Time.now

#***********l'affichage de factoriel**********
puts"le factoriel calcule avec la methode recursive de #{n} est :#{f_rec}" 
puts"le factoriel calcule avec la methode sequentiel de #{n} est :#{f_seq}" 
puts"le factoriel calcule avec la methode parallele de #{n} est :#{f_para}" 

#*************la comparaison du temps d'execution*************
puts"le temps d'execution en sequentiel recursive est #{fin_rec-deb_rec}"
puts"le temps d'execution en sequentiel est #{fin_seq-deb_seq}"
puts"le temps d'execution en parallele est #{fin_para-deb_para}"

