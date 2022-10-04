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
  print"entrer la chaine a compresse-->"
  str=gets.chomp

 rle_seq=rle_sequentiel(str)
 
#*****************le calcul du temps d'execution*****************
 starting_parallele = Time.now
       rle_para=rle_parallele(str)
  ending_parallele = Time.now
  
  #***************l'affichage de RLE  en parallele et en sequentiel**************
  puts "Le RLE en sequentiel est: #{rle_seq}"
  puts "Le RLE en parallele est: #{rle_para}"
  
  #****************la comparaison des tailles ****************************
  puts"la longueur de la chaine avant l'application de RLE est: #{str.size}"
  puts"la longueur de la chaine apres l'application de RLE est: #{rle_para.size}"
  
#*****************l'affichage du temps d'execution*****************
  puts"le temps d'execution pour parallele est: #{ending_parallele-starting_parallele}"
  
