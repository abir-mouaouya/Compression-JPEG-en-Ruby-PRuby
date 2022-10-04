require'pruby'

#****************la fonction sequentiel**********************

def transpose_sequentiel(a)
   c=Array.new(a[0].size){Array.new(a.size)}
   (0...a[0].size).each do |i|
      (0...a.size).each do |j|
         c[i][j]=a[j][i]
      end
   end
   c
end

#****************la fonction parallele**********************

def transpose_parallele(a)
    c=Array.new(a[0].size){Array.new(a.size)}
    (0...a[0].size).peach do |i|
        (0...a.size).pmap(nb_threads:PRuby.nb_threads) do |j|
           c[i][j]=a[j][i]
        end
    end
    c
end

#****************l'affichage des tableau**********************

def affichage(a,n)
  (0...n).each do |k|
    puts "#{a[k]}\t"
    puts"\n"
  end
end

a=[[1,2,3,15,45,57,12,23],[4,5,6,25,58,5,8,7],[4,58,66,25,561,5,80,74]]

#**************le calcul du temps d'execution*****************

debut_sequentiel=Time.now
   c_seq=transpose_sequentiel(a)
fin_sequentiel=Time.now

debut_parallele=Time.now
   c_para=transpose_parallele(a)
fin_parallele=Time.now

#******************l'affichage de A et C_seq et c_para*********
puts"la matrice A est:"
affichage(a,a[0].size)
puts"la transposé de A calculé en sequentiel est:"
affichage(c_seq,c_seq.size)
puts"\n la transposé de A calculé en parallele est: "
affichage(c_para,c_para.size)

#***************comparaison des temps d'execution***************
 puts"le temps d'execution en sequentiel est #{fin_sequentiel-debut_sequentiel}"
 puts"le temps d'execution en parallele est #{fin_parallele-debut_parallele}"
 
