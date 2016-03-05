# Clustering Algorithm
# hierarchical clustering
# top down approach
# input data is @data
use Data::Dumper;

# Open the lev file
open( my $fh, '<', "lev.txt" ) or die "Can't open lev.txt: $!";

@data = ();

$i = 0;
while ( my $line = <$fh> )
{
  my @temp = split(",", $line);
  push(@data, \@temp);
  warn Dumper $i;
  $i++;
}
close $fh;
warn Dumper "----------------------------------------------------------finished input";
$Number_of_instances=11367;
$Number_of_dimensions=11367;
$Number_of_clusters = 1;
$End_Number_of_clusters = $Number_of_instances;




$clusters[0]="";
for ($i=0; $i<$Number_of_instances; $i++)
{
  $clusters[0] = $clusters[0].$i."_";
}


while ( $Number_of_clusters < $End_Number_of_clusters)
{

   $dist=0;
   $d=0;
   for ($ii=0; $ii<$Number_of_clusters; $ii++)
   {
        
           $d=0;
           @instances1 = split("_", $clusters[$ii]);

           for($ins1=0; $ins1 < @instances1-1; $ins1++)
           {
             
              for($ins2=$ins1+1; $ins2 < @instances1; $ins2++)
              {
                 for($y=0; $y<$Number_of_dimensions; $y++)
                 {
                    $d=  $d + ($data[$instances1[$ins1]][$y]-$data[$instances1[$ins2]][$y])**2;
                 }

                  $d=sqrt($d);
                   if ($d  > $dist)
                   {
                       $cl_ind=$ii;
                       $ind1=$ins1;
                       $ind2=$ins2;
                       $dist=$d;
                   }   
 
              }
           } 
      
      
   }
   split_cluster($cl_ind, $ind1, $ind2); 
   $Number_of_clusters=$Number_of_clusters+1;

   print "\n";
   print "========================================";
   print "\n";
 
   for ($i=0; $i < $Number_of_clusters; $i++)
   {
       print "Cluster $i   $clusters[$i] \n";
   }     
}        
 

sub split_cluster ($$$)
{
  
    my ($c,$a,$b)=@_;

     @instances1 = split("_", $clusters[$c]);


      $clusters[$c]="";
      $clusters[$Number_of_clusters]="";


     for($ins1=0; $ins1 < @instances1; $ins1++)
     {
         $d1=0; 
         for($y=0; $y<$Number_of_dimensions; $y++)
         {
              $d1=  $d1 + ($data[$instances1[$ins1]][$y]-$data[$instances1[$a]][$y])**2;
         }

  
         $d2=0;
         for($y=0; $y<$Number_of_dimensions; $y++)
         {
             $d2=  $d2 + ($data[$instances1[$ins1]][$y]-$data[$instances1[$b]][$y])**2;
         }


     
         if ($d1 >=$d2)
         {         
             $clusters[$Number_of_clusters]=$clusters[$Number_of_clusters].$instances1[$ins1]."_";
             
         }
         else
         {
            $clusters[$c]=$clusters[$c].$instances1[$ins1]."_";
        
         }
      }         
}













