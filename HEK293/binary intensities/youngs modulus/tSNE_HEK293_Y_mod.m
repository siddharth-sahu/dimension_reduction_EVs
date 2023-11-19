%% import data
clc;
clear;
close all;
fpath='C:\Users\sahus\Google Drive\14 Scripts\tSNE analysis\HEK293\youngs modulus\';
fname='Single_EV_data_integrated_intensity_Fredrik_new.xlsx';
fullname=horzcat(fpath,fname);
inputData=readtable(fullname);

%% Select Columns
sl_no=inputData{:,1};
equivDia=inputData{:,7};
intSumCD9=inputData{:,11};
intSumCD63=inputData{:,12};
intSumCD81=inputData{:,13};
youngsMod = inputData{:,25};

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

%% t-SNE calculation
MAT=[equivDia bi_intSumCD9 bi_intSumCD63 bi_intSumCD81 youngsMod];
rng default;
opts = statset('MaxIter',5000);

% perplex = linspace(5, 50, 46);
perplex = 21;
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

% labels = bi_intSumCD9+bi_intSumCD63+bi_intSumCD81;
% clr = 'rbgm';
% h=gscatter(Y(:,1),Y(:,2), labels, clr, '.', 25);
      
sz = 36;
c = youngsMod;
colormap jet;
scatter(Y(:,1),Y(:,2),sz,c,'filled');
colorbar;

figure(1);
xlabel('t-SNE_1');
ylabel('t-SNE_2');
% xlim([-1300 1300]);
set(gca,'FontSize',14);

% legend('# channel(s) = 1','# channel(s) = 2','# channel(s) = 3')
% title('tSNE ');
print(figure(1),'mahalanobis_16_youngsMod','-dpng','-r1000');

% figure(2);
% scatter(sl_no, equivDia);

