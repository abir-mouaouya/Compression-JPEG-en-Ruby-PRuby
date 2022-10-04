#!/usr/bin/env ruby

require 'cmath'
require 'pruby'

# l'image est diviser à un bloc de 8 x 8 
N = 8

# Image d'origine
h = [[54, 76, 101, 117, 106, 80, 35, 24],
     [46, 82, 182, 215, 221, 114, 21, 30],
     [75, 94, 190, 253, 242, 125, 43, 36],
     [51, 78, 195, 250, 249, 100, 19, 36],
     [47, 50, 84, 108, 82, 37, 28, 35],
     [43, 38, 40, 40, 35, 23, 40, 40],
     [36, 64, 68, 69, 75, 61, 43, 39],
     [61, 45, 59, 63, 58, 51, 47, 45]] 

# Image dct
image_dct = Array.new(N){Array.new(N)}

################################################################################################
###################################     Calcule de DCT :     ###################################
################################################################################################

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

#calcul de temps de 
starting = Time.now
image_dct = DCT(h,PRuby.nb_threads)
ending = Time.now
image_dct.each do |x|
  x.each do |y|
    print y, "\t"
  end 
  print"\n"
end
elapsed = ending - starting
puts"le temps de calcul de la DCT :  #{elapsed} s"


################################################################################################
###################################     Quantification      ####################################
################################################################################################

K = 1 # Pas de quantification
# Initialisation de la matrice de quantification qui est la matrice standardisée dite de facto
q = [[16,11,10,16,24,40,51,61],
     [12,12,14,19,26,58,60,55],
     [14,13,16,24,40,57,69,56],
	 [14,17,22,29,51,87,80,62],
     [18,22,37,56,68,109,103,77],
     [24,35,55,64,81,104,113,92],
	 [49,64,78,87,103,121,120,101],
     [72,92,95,98,112,100,103,99]]
Q = Array.new(N){Array.new(N)}

# Initialisation de la matrice DCT arrondie
#matrice_dct = [[649,93,-290,-51,71,-13,15,20], [187,50,-181,-20,34,-15,15,6],
#			   [-69,-20,84,32,-43,-2,2,-13], [-173,-26,141,13,-42,6,-13,-14],
#			   [-32,4,24,-3,4,10,0,-3], [38,4,-29,2,-2,-10,-5,0], [-30,-5,53,15,-4,19,-7,-5],
#			   [-15,0,32,9,-14,9,-7,-14]]

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


# Exécution parallèle
temps_debut = Time.now
image_quant = quant_P(image_dct, q, PRuby.nb_threads)
temps_fin = Time.now
temps_ecoule = temps_fin - temps_debut

print "\n*** Execution parallele ***\n"
print "Matrice quantifiee par la matrice de quantification facto : \n"
afficher_matrice(image_quant)
print "Temps ecoule pour la quantification : ", temps_ecoule, " s\n\n"

################################################################################################
######################################     Zig zag      ########################################
################################################################################################
mat= [[40,8,-29,-3,2,0,0,0],
      [15,-4,-12,-1,1,0,0,0],
      [-4,-1,5,1,-1,0,0,0],
      [-12,-1,6,0,0,0,0,0],
      [-1,0,0,0,0,0,0,0], 
      [1,0,0,0,0,0,0,0], 
      [0,0,0,0,0,0,0,0], 
      [0,0,0,0,0,0,0,0]] 
def zigzag (mat)
    nbLigne=8;
    nbcol=8;
    out = Array.new(64)
    row=1;
    col=1;
    index=1
    attributsParam = [nil];
       
    for i in 0..63
        out[i]=nil;
    end
        
    while( row <= nbLigne or col <= nbcol)
        if( row==1 && ((row+col)%2)==0 && col != nbcol )
            out[index]=mat[row-1][col-1];
            col=col+1;							#right => top
            index=index+1;		
        else 	
            if (row==nbLigne && ((row+col)%2)!=0 && col != nbcol)
            out[index] = mat[row-1][col-1]
            col=col+1;							#right => bottom
            index=index+1;		
            else
                if (col==1 && ((row+col)%2)!=0 && (row != nbLigne))
                out[index]=mat[row-1][col-1]
                row=row+1;							#down => left
                index=index+1;			
                else
                    if (col==nbcol && (row+col)%2==0 && row!=nbLigne)
                    out[index]=mat[row-1][col-1]
                    row=row+1;							#down=>right
                    index=index+1;				
                    else
                        if ((col !=1) && (row != nbLigne) && (row+col)%2 !=0)
                        out[index]=mat[row-1][col-1]
                        row=row+1;		
                        col=col-1;	#diagonal left=> down
                        index=index+1;					
                        else
                            if ((row != 1) && (col != nbcol) && ((row+col)%2 )==0)
                            out[index]=mat[row-1][col-1]
                            row=row-1;	
                            col=col+1;	                  #diagonal right=> up
                            index=index+1;					
                            else
                                if (row==nbLigne && col==nbcol)
                                    out[63]=mat[7][7];							
                                break	
                                end
                            end
                        end
                    end 
                end
            end 	         	 	      									
        end 
    end

    print out;
    print "\n"
    print"la taille de sortie est"
    print  out.size() 
    print "\n"
    #transfrome en une chaine des 0 ET 1 
    s=""
    l=""

    for i in 1..63 
    l=""
        if(out[i] >= 0) 
        #pour presenter sur 8bit 
            l=out[i].to_s(2)
            if(l.size()<8)
                for j in 1..8-l.size()
                    l="0"+l
                end 
            end
            s=s+l
        else
            l=(-out[i]).to_s(2)
            if(l.size()<8)
                for j in 1..8-l.size()-1
                    l="0"+l
                end 
            end
            l="1"+l  
            s=s+l
        end
    end
    puts"la sequence binaire est : "
    puts s;
    print"la taille de sortie bianire est  "
    print  s.size() 
    print "\n"

    return s
end 
    
s = zigzag(mat);

################################################################################################
####################################     Codage RLE      #######################################
################################################################################################

require'pruby'

#***************************la fonction parallele**************************
def rle_sequentiel(str)
  current=str[0]
  n=0
  tab=[]
    str.each_char do |char|
        if char==current
           n=n+1
        else
           tab << n
           tab << current
           current=char
           n=1
        end
     end
     tab << n
     tab << current
     result=tab.join
  return result
end

#***************************la fonction parallele**************************

def rle_parallele(str)
   def rle_sous_chain(str1)
       str=str1.join   #convertir un tableau en string
       current=str[0]
       tab=[]
       n=0
       str.each_char do |char|  #parcourir tout la chaine
           if char==current
              n=n+1
           else
              tab << n    #stocker le nombre de repetition de mot dans le tableau
              tab << current #stocket le mot
              current=char
              n=1
           end
       end
      tab << n
      tab << current
    return tab
   end
   print"entrer le numero du processus"
   npr=gets.chomp.to_i
   nbr1=str.length
   if npr.even?
     if nbr1/npr<=1
        abort "il faut diminuer le nombre de processus"
     end
   else
    if nbr1/npr<1
        abort "il faut diminuer le nombre de processus" #quitter le programme
     end
   end
   str2=str.split("",nbr1)   #convertir le string en un tableau de nbr1 element

   #***********diviser la chaine en des sous chaines****************
   
   str1=Array.new(str2.size){Array.new(str2.size){0}}
      (0...npr).each do |k|
         if k==npr-1
            str1[k]=str2
         else
            str1[k]=str2.first(nbr1/npr) #recuperer les premiers elements de la chain
            n=str2.size-str1[k].size
            str2=str2.last(n)           #recuperer les derniers elements de la chain
         end
       end

#**************calculer le RLE pour chaque sous chaine******************
    r=[];
    i=0
    (0...npr/2).each do |k|
         PRuby.pcall( lambda{r[k+i]=rle_sous_chain(str1[k+i])},lambda{r[k+i+1]=rle_sous_chain(str1[k+i+1])} )
         i=i+1
         unless npr.even?  #si le nombre de processus est impaire
            r[npr-1]=rle_sous_chain(str1[npr-1])
         end
    end

=begin             **************************
verifier que la dernier element de la sous chaine traiter est different de la premier element de la sous chain suivant
                   **************************
=end               
   result=r[0]
      (1...npr).each do |k|
          if result[result.length-1]==r[k][1]
             n=result[result.length-2].to_i+r[k][0].to_i
             result[result.length-2]=n
             result+=r[k][2...r[k].size]
          else
             result+=r[k]
          end
      end
      retour=result.join
    return retour
  end 
  
  #*****************la saisie de la chain***********************
  #print"entrer la chaine a compresse-->"
  #str=gets.chomp

 rle_seq=rle_sequentiel(s)
 
#*****************le calcul du temps d'execution*****************
starting_parallele = Time.now
rle_para=rle_parallele(s)
ending_parallele = Time.now
  
  #***************l'affichage de RLE  en parallele et en sequentiel**************
  puts "Le RLE en sequentiel est: #{rle_seq}"
  puts "Le RLE en parallele est: #{rle_para}"
  
  #****************la comparaison des tailles ****************************
  puts"la longueur de la chaine avant l'application de RLE est: #{s.size}"
  puts"la longueur de la chaine apres l'application de RLE est: #{rle_para.size}"
  
#*****************l'affichage du temps d'execution*****************
  puts"le temps d'execution pour parallele est: #{ending_parallele-starting_parallele}"
  
