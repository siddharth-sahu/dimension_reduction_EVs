clear
close all
fpath='G:\My Drive\qnn-lab\sara\tsne\'
fname='Single_EV_data_integrated_intensity.csv'
fullname=horzcat(fpath,fname);
A=readmatrix(fullname)
d_eq=2*sqrt(A(:,5)/2/pi);
intpb=A(:,10)
intrpe=A(:,11)
intapc=A(:,12)

s=zeros(length(intpb),1)


for i=1:length(intpb)
if intpb(i)~=0
s(i)=s(i)+1
end
if intrpe(i)~=0
s(i)=s(i)+1
end
if intapc(i)~=0
s(i)=s(i)+1
end
end
MAT=[d_eq intpb intrpe intapc s]

rng('default')
Y=tsne(MAT,'Algorithm','exact','Distance','cosine')
gscatter(Y(:,1),Y(:,2),s)

xlabel('tSNE 1')
ylabel('tSNE 2')
set(gca,'FontSize',14)
legend('# channel(s) = 1','# channel(s) = 2','# channel(s) = 3')
title('tSNE - Cosine')
figure; 

rng('default')
Y=tsne(MAT,'Algorithm','exact','Distance','mahalanobis')
gscatter(Y(:,1),Y(:,2),s)
xlabel('tSNE 1')
ylabel('tSNE 2')
set(gca,'FontSize',14)
legend('# channel(s) = 1','# channel(s) = 2','# channel(s) = 3')
title('tSNE - Mahalanobis')


% https://www.mathworks.com/help/stats/tsne.html
