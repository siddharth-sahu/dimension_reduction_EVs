%% Import Data
clc;
clear;
close all;
fpath='C:\Users\sidsa652\Google Drive\14 Scripts\tSNE analysis\EVB239\';
fname='Single_EV_data_EVB329_integrated_intensity.xlsx';
fullname=horzcat(fpath,fname);
inputData=readtable(fullname);

%% Select Columns
sl_no=inputData{:,1};
equivDia=inputData{:,7};
intSumCD9=inputData{:,11};
intSumCD63=inputData{:,12};
intSumCD81=inputData{:,13};

diaMin = min(equivDia);
diaMax = max(equivDia);
diaLower25 = diaMin + (diaMax - diaMin)/4;
dia25_50 = diaMin + (diaMax - diaMin)/2;
dia50_75 = diaMin + 3*(diaMax - diaMin)/4;

%% Convert intensities into binary values
num_only_one_channel=0;

for i=1:length(equivDia)
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
end

bi_intSumCD9 = bi_intSumCD9';
bi_intSumCD63 = bi_intSumCD63';
bi_intSumCD81 = bi_intSumCD81';

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
MAT=[equivDia bi_intSumCD9 bi_intSumCD63 bi_intSumCD81];
rng default;
opts = statset('MaxIter',5000);

% perplex = linspace(5, 50, 46);
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

labels = groups7;
clr = linspecer(7);
h=gscatter(Y(:,1),Y(:,2), labels, clr, '.', 25);
lgd=legend('Orientation','horizontal', 'Location', 'south');
lgd.FontSize = 10;

% sz = 36;
% c = equivDia;
% colormap jet;
% scatter(Y(:,1),Y(:,2),sz,c,'filled');
% colorbar;

figure(1);
xlabel('tSNE1');
ylabel('tSNE2');
% xlim([-2000 2400]);
ylim([-2750 2000]);
set(gca,'FontSize',1);
set(gca,'FontSize',14);

print(figure(1),'EVB239_7groups','-dpng','-r1000');

