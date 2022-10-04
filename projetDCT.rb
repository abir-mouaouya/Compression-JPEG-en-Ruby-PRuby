#!/usr/bin/env ruby
require 'cmath'
require 'pruby'
# l'image est diviser à un bloc de 8 x 8 
N = 8
#################################################     Calcule de DCT : 
#calcul des coefficients c 
def c(a)	
    if a==0
        d=1/Math.sqrt(2)
    else
        d=1 
    end
  return  d 
end 
#la sommation de cosinus discert  
def som(u,v,img,nb_threads=PRuby.nb_threads)
  #initialisons la somme à 0 
  s=0	    
   # on divise les taches par threads cad par nombre de coeur processeur sur notre machine pour la boucle de i ainsi que de h 
   (0..N-1).peach(nb_threads:nb_threads) do |i|
        (0..N-1).peach( nb_threads:nb_threads ) do |j| 	
      #appliquons la formule de dct   
      s=s+(Math.cos((2*i+1)*u*(Math::PI)/(2*8))*Math.cos((2*j+1)*v*(Math::PI)/(2*8))*img[i][j])    
    end
  end 
  return s
end

#calcul de DCT
def dct(i,j,img)
   return 0.25*c(i)*c(j)*som(i,j,img,PRuby.nb_threads)
end
def DCT(img,nb_threads=PRuby.nb_threads)
    #création du nouveau bloc DCT 
    img_DCT = Array.new(8){Array.new(8)}
    #division des taches sur les coeur de notre machine 
       (0..7).peach(nb_threads:nb_threads ) do |i|
        (0..7).peach(	nb_threads:nb_threads) do |j| 
            img_DCT[i][j] = dct(i,j,img).round(0)
        end
    end  
	return img_DCT
end

#################################################     Fonctionnement : 
im = Array.new(N){Array.new(N)}
h = [[54, 76, 101, 117, 106, 80, 35, 24],[46, 82, 182, 215, 221, 114, 21, 30], [75, 94, 190, 253, 242, 125, 43, 36], [51, 78, 195, 250, 249, 100, 19, 36], [47, 50, 84, 108, 82, 37, 28, 35], [43, 38, 40, 40, 35, 23, 40, 40], [36, 64, 68, 69, 75, 61, 43, 39], [61, 45, 59, 63, 58, 51, 47, 45]] 
#calcul de temps de 
starting = Time.now
im = DCT(h,PRuby.nb_threads)
ending = Time.now
im.each do |x|
  x.each do |y|
    print y, "\t"
  end 
  print"\n"
end
elapsed = ending - starting
puts"le temps 1  #{elapsed}"

