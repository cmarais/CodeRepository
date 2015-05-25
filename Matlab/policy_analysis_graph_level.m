function [PFL] = policy_analysis_graph_level(StateSpace, Policy, Price, Pit)
% script created by Colette Marais 01/10/2013

% description
% ~~~~~~~~~~~
% POLICY_GRAPH_LEVEL Plots a two dimensional representation of the  policy  
% function for the three lower levels in a pit 
%
% Input Arguments:
%
%       StateSpace      : The model state space
%       Policy          : The policy function which consists of
%                         probabilities of transitioning to new pits
%       Price           : The prices that are used as x-coordinates
%       Pit             : The pit number
%
%
% Output Arguments:
%
%       PFL            : The figure
%


%% Definitions

% Figure Settings

r = 6;                                                                     % Number of rows in the subplot
c = 5;                                                                     % Number of columns in the subplot
xmin = min(Price);
xmax = max(Price);
ymin = 1;
ymax = 4;
zmin = 0;
zmax = 1.5;


%% Plot the figure

fig_name = 'Policy Function Analysis Across Levels ';
Figure_Settings;
PFL = figure('name',fig_name,...
      'units','centimeters',...
      'position',[fig_left_pos fig_bottom_pos fig_width fig_height],...
      'papersize',[fig_width fig_height],...
      'PaperPositionMode','auto');
  
  for i = 1:3
      for j = 1:4
          
          subplot(3,4,(i-1)*4+j)
          
          % Represent the policy space on a grid
          
          pol_spec = zeros(4,15);
          
          for k = 1:4
              pol_spec(k,:) = Policy((StateSpace(:,1) == j & StateSpace(:,2) == k & StateSpace(:,4) == i+3),Pit);
          end
          
          h = image(Price,1.5:4.5,pol_spec*255);                           % Plot the policy space

          set(gca, 'YTick',1.5:4.5,'YTickLabel',1:4)
          
          set(gca,'ZTick',0:1)

          % Assign y-labels to the first figure in a new row
          
          if ((i-1)*4+j == (i-1)*4+1)
              ylabel(['Level ',num2str(i+3),''],'fontsize',label_fontsize,'Interpreter','LaTex')
          end
          
          % Assign titles to all figures at the top of a column
          
          if ((i-1)*4+j == 1 || (i-1)*4+j == 2 || (i-1)*4+j == 3 || (i-1)*4+j == 4)
              title(['$\{ c_{i,k-1}$ \thinspace , $c_{',num2str(j),',k-2}$ \thinspace $\}$'],'fontsize',label_fontsize,'Interpreter','LaTex')
          end
          
          view([0 90])                                                     % Change the view of the graph to be from above
          set(gca,'Ydir','normal')
          box off
      end
  end
 
%% Define graph characteristics  

 % Figure colours

 N=2;
 L = line(ones(N),ones(N),'LineWidth',2);
 set(L,{'color'},mat2cell([0 0 0.8 ; 0.8 0 0],ones(1,N),3));
 
 % Legend
 
 legOri = 'horizontal';
 k = legend('$a_t = 0$','$a_t = 1$','Orientation',legOri');
 set(k,'Interpreter','LaTex')
 set(k,'fontsize',label_fontsize, 'Position',[0.4, 0.02, 0.25, 0.02])
 legend boxoff
 
 % x- and y-labels
 
 a = xlabel('Price (\$/kg)','fontsize',label_fontsize,'Interpreter','LaTex');
 set(a, 'position',[-215 0.5 1.00011])
 b = ylabel('Ore Category, $i$','fontsize',label_fontsize,'Interpreter','LaTex' );
 set(b, 'position',[-620 9 1.00011])
 set(gcf, 'Renderer', 'painters');

%% Output the eps file to Windows or Mac

print(gcf,'-depsc','F:\Dropbox\PHD\Finale Tesis Dokument\Figures\Empirical_Model\Policy_Anal_Pitv1_1.eps','-r2048')
%print(gcf,'-depsc','/Users/Colette/Dropbox/PHD/Finale Tesis Dokument/Figures/Empirical_Model/Policy_Anal_Pitv1_1.eps','-r2048')


end
