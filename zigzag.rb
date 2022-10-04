def zigzag ()
nbLigne=8;
nbcol=8;
out = Array.new(64)
row=1;
col=1;
index=1
attributsParam = [nil];
mat= [[40,8,-29,-3,2,0,0,0],
      [15,-4,-12,-1,1,0,0,0],
      [-4,-1,5,1,-1,0,0,0],
      [-12,-1,6,0,0,0,0,0],
      [-1,0,0,0,0,0,0,0], 
      [1,0,0,0,0,0,0,0], 
      [0,0,0,0,0,0,0,0], 
      [0,0,0,0,0,0,0,0]]    
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
puts"la séquence binaire est : "
puts s;
print"la taille de sortie bianire est  "
print  s.size() 
print "\n"
end 

zigzag();
