clear

// Loi normale
function [x]=normale(y,m,s2)
  x=%e^(-(y-m).^2/2/s2)/sqrt(2*%pi*s2)
endfunction;

// Ouvrir le fichier de donnees (nombre de crabes par intervalle)
x=fscanfMat('crabe.txt');
x=x;

// intervalles
y=.580+.002+.004*[0:28];
yM=y+.002;
ym=y-.002;
Max=25;

// Dessiner la loi normale correspondante
// A FAIRE
probas = x / sum(x);
ls_abs = [0.58:0.004:0.696];
moyenne = y*probas
var = (y.^2)*probas - moyenne^2;
sigma = sqrt(var)
densite = normale(ls_abs,moyenne,var);
plot(ls_abs,densite/sum(densite));

// Tracer l'histogramme
// A FAIRE
bar(y,x/sum(x));



// TEST DU CHI 2


// Cette fonction retourne la p valeur P(chi2>zeta_n) 
// du test du chi2 d'adequation de loi

// N est un vecteur ligne des occurences observees
// p0 est un vecteur ligne correspondant a la loi sous H0

function[proba]=test_chi2(N,p0)
  n=sum(N);// taille de l'echantillon observe
  // calcul de zeta_ n
  zeta_n=n*sum(((N/n-p0).^2)./p0);
  // nombre de degres de liberte  (= nombre de classes dans N-1)
  d= length(N)-1;
  // on calcule la proba pour un chi 2 � d-1 degres d'etre superieur a zeta
  [p,q]=cdfchi("PQ",zeta_n,d)
  proba=q;
endfunction;


// On ne consid�re que les classes ayant un effectifs sup�rieur � 5
effectifs = x(2:27);
classes = y(2:27);

p_empirique = effectifs / sum(effectifs);
moyenne = classes * p_empirique;
var = ((classes-moyenne).^2) * p_empirique;

p0 = normale(classes,moyenne,var)';
p0 = p0 /sum(p0);

p_valeur = test_chi2(effectifs,p0)



// Donnees
pi0=[1; 3 ; 6]/10;
pi=pi0;
mu=[.57; .67; .67];
s2=[1 ;1;1]/10000;

rho=ones(3,1000);

// Algorithme EM pour les crabes 
//------------------------------

N=1000;
R=zeros(8,N+1);
R(:,1)=[mu(1);mu(2);mu(3);pi(1);pi(2);s2(1);s2(2);s2(3)];


Y = [];
[r,n]=size(y);
for l=1:n
	for m=1:x(l)
		Y = [Y ; y(l)];
	end;
end;



function[proba]=probabilite(i,ite)
	if i==1
		proba = R(4,ite);
	end;
	if i==2
		proba = R(5,ite);
	end;
	if i==3
		proba = 1 - R(4,ite) - R(5,ite);
	end;  
endfunction;



for ite=1:N
	for k=1:N
	  // Iteration k
	  // A FAIRE
	  // Calcul de rho
	  for i=1:3
	  	rho(i,k) = probabilite(i,ite) * normale(Y(k),R(i,ite),R(i+5,ite));
	  end;
	  rho(:,k) = rho(:,k) / sum(rho(:,k));
	end;
	// calcul de pi(1), pi(2)
	R(4,ite+1) = (1/N) * sum(rho(1,:));
	R(5,ite+1) = (1/N) * sum(rho(2,:));

	// calcul mu
	R(1,ite+1) = rho(1,:) * Y / sum(rho(1,:));
	R(2,ite+1) = rho(2,:) * Y / sum(rho(2,:));
	R(3,ite+1) = rho(3,:) * Y / sum(rho(3,:));

	// calcul sigma
	R(6,ite+1) = ( rho(1,:) * ((Y-R(1,ite+1)).^2) ) / sum(rho(1,:));
	R(7,ite+1) = ( rho(2,:) * ((Y-R(2,ite+1)).^2) ) / sum(rho(2,:));
	R(8,ite+1) = ( rho(3,:) * ((Y-R(3,ite+1)).^2) ) / sum(rho(3,:));
end;


// Affichages
// A FAIRE

figure(2);
bar(y,x/sum(x));
ls_abs = [0.58:0.004:0.696];
densite = normale(ls_abs,R(1,N+1),R(6,N+1)) * R(4,N+1);
densite = densite + normale(ls_abs,R(2,N+1),R(7,N+1)) * R(5,N+1);
densite = densite + normale(ls_abs,R(3,N+1),R(8,N+1)) * (1- R(4,N+1)- R(5,N+1));
plot(ls_abs,densite/sum(densite));