%% import data
clc;
clear;
close all;

% HEK 293:
% fpath='C:\Users\sahus\Google Drive\14 Scripts\tSNE\HEK293\binary intensities\';
% fname='Single_EV_data_integrated_intensity_Fredrik_new.xlsx';

% EVB 239:
fpath='C:\Users\sahus\Google Drive\14 Scripts\tSNE\EVB239\';
fname='Single_EV_data_EVB329_integrated_intensity.xlsx';

fullname=horzcat(fpath,fname);
inputData=readtable(fullname);

%% Select Columns
equivDia=inputData{:,7};
intSumCD9=inputData{:,11};
intSumCD63=inputData{:,12};
intSumCD81=inputData{:,13};

% Normalise intentisities
intSumCD9(intSumCD9==0)=inf;
minCD9 = min(intSumCD9);
intSumCD9 = intSumCD9/minCD9;
intSumCD9(intSumCD9==inf)=0;

intSumCD81(intSumCD81==0)=inf;
minCD81 = min(intSumCD81);
intSumCD81 = intSumCD81/minCD81;
intSumCD81(intSumCD81==inf)=0;

intSumCD63(intSumCD63==0)=inf;
minCD63 = min(intSumCD63);
intSumCD63 = intSumCD63/minCD63;
intSumCD63(intSumCD63==inf)=0;


diaMin = min(equivDia);
diaMax = max(equivDia);
diaLower25 = diaMin + (diaMax - diaMin)/4;
dia25_50 = diaMin + (diaMax - diaMin)/2;
dia50_75 = diaMin + 3*(diaMax - diaMin)/4;

minCD9 = min(intSumCD9);
minCD63 = min(intSumCD63);
minCD81 = min(intSumCD81);
maxCD9 = max(intSumCD9);
maxCD63 = max(intSumCD63);
maxCD81 = max(intSumCD81);
minInt = min([minCD9 minCD63 minCD81]);
maxInt = max([maxCD9 maxCD63 maxCD81]);
intLower25 = minInt + (maxInt - minInt)/4;
int25_50 = minInt + (maxInt - minInt)/2;
int50_75 = minInt + 3*(maxInt - minInt)/4;

%% Convert intensities into binary values
num_only_one_channel=0;

for i=1:length(equivDia)
    % converting into binary
    if intSumCD9(i)~=0
        bi_intSumCD9(i) = 1;
    else
        bi_intSumCD9(i) = 0;
    end
    
    if intSumCD63(i)~=0
        bi_intSumCD63(i) = 1;
    else
        bi_intSumCD63(i) = 0;
    end
    
    if intSumCD81(i)~=0
        bi_intSumCD81(i) = 1;
    else
        bi_intSumCD81(i) = 0;
    end    
    
    % number of EVs with only one of the antibodies present
    if (intSumCD9(i)==0 && intSumCD63(i)==0)||(intSumCD9(i)==0 && intSumCD81(i)==0)||(intSumCD63(i)==0 && intSumCD81(i)==0)
         num_only_one_channel = num_only_one_channel+1;
    end
    if(equivDia(i) < diaLower25)
        diaThreshold(i) = 1;
    elseif(equivDia(i) < dia25_50)
        diaThreshold(i) = 2;
    elseif(equivDia(i) < dia50_75)
        diaThreshold(i) = 3;
    else
        diaThreshold(i) = 4;
    end
    
    %binning the intensities
     if intSumCD9(i)==0
         bin_intSumCD9(i) = 0;
     elseif(intSumCD9(i) < intLower25)
        bin_intSumCD9(i) = 1;
    elseif(intSumCD9(i) < int25_50)
        bin_intSumCD9(i) = 2;
    elseif(intSumCD9(i) < int50_75)
        bin_intSumCD9(i) = 3;
    else
        bin_intSumCD9(i) = 4;
     end
    
      if intSumCD63(i)==0
         bin_intSumCD63(i) = 0;
     elseif(intSumCD63(i) < intLower25)
        bin_intSumCD63(i) = 1;
    elseif(intSumCD63(i) < int25_50)
        bin_intSumCD63(i) = 2;
    elseif(intSumCD63(i) < int50_75)
        bin_intSumCD63(i) = 3;
    else
        bin_intSumCD63(i) = 4;
     end
    
     if intSumCD81(i)==0
         bin_intSumCD81(i) = 0;
     elseif(intSumCD81(i) < intLower25)
        bin_intSumCD81(i) = 1;
    elseif(intSumCD81(i) < int25_50)
        bin_intSumCD81(i) = 2;
    elseif(intSumCD81(i) < int50_75)
        bin_intSumCD81(i) = 3;
    else
        bin_intSumCD81(i) = 4;
     end
end

bi_intSumCD9 = bi_intSumCD9';
bi_intSumCD63 = bi_intSumCD63';
bi_intSumCD81 = bi_intSumCD81';

bin_intSumCD9 = bin_intSumCD9';
bin_intSumCD63 = bin_intSumCD63';
bin_intSumCD81 = bin_intSumCD81';


% number of zero elements
num0_CD9 = nnz(~intSumCD9);
num0_CD63 = nnz(~intSumCD63);
num0_CD81 = nnz(~intSumCD81);

% categorising into 7 groups
bi_sum = bi_intSumCD9 + bi_intSumCD63 + bi_intSumCD81;
for i=1:length(bi_sum)
   if bi_sum(i)==3
       groups7(i) = 7;
   elseif bi_sum(i) == 2
       if bi_intSumCD81(i) == 0
           groups7(i) = 4;
       elseif bi_intSumCD63(i) == 0
           groups7(i) = 5;
       elseif bi_intSumCD9(i) == 0
           groups7(i) = 6;
       end
   elseif bi_sum(i) == 1
       if bi_intSumCD9(i) == 1
           groups7(i) = 1;
       elseif bi_intSumCD63(i) == 1
           groups7(i) = 2;
       elseif bi_intSumCD81(i) == 1
           groups7(i) = 3;
       end
   end
end

%% t-SNE calculation

% binary intensities:
% MAT=[equivDia bi_intSumCD9 bi_intSumCD63 bi_intSumCD81];

% intensities classified into slabs:
MAT=[equivDia bin_intSumCD9 bin_intSumCD63 bin_intSumCD81];

% actual intensities
% MAT=[equivDia intSumCD9 intSumCD63 intSumCD81];

rng default;
opts = statset('MaxIter',5000);

% perplex = linspace(5, 50, 46);

% for HEK 293:
% perplex = 28;

% for EVB 239:
perplex = 17;

% for i=1:length(perplex)
    [Y, loss] = tsne(MAT,'Algorithm','exact', 'distance', 'mahalanobis','perplexity', perplex, 'LearnRate',1500,...
   'Options',opts);
%     loss_matrix(i) = loss;
% end

%% plot and export

% figure(1);
% plot (perplex, loss_matrix);
% xlabel('perplexity');
% ylabel('t-SNE loss');
% title ('tSNE loss vs. perplexity');
% print(figure(1),'tSNE loss','-dpng','-r1000');

labels = bin_intSumCD9 + bin_intSumCD63 + bin_intSumCD81;
clr = linspecer(7);
h=gscatter(Y(:,1),Y(:,2), labels, clr, '.', 25);
% xlim([-1800 1800]);
% ylim([-1800 2100]);
lgd=legend('Orientation','horizontal');
lgd.FontSize = 10;
      
% sz = 36;
% c = equivDia;
% colormap jet;
% scatter(Y(:,1),Y(:,2),sz,c,'filled');
% xlim([-1800 1800]);
% ylim([-1800 2100]);
% colorbar;

% figure(1);
% xlabel('tSNE1');
% ylabel('tSNE2');
% xlim([-1800 1800]);
% ylim([-1800 2100]);
% set(gca,'FontSize',14);

print(figure(1),'normalised_EVB_dia_binned_sum','-dpng','-r1000');

