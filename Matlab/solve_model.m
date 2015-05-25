function [V, Prob0, count] = solve_model( utility_mine, StateSpace, V, Prob0, diffEV1, diffEV2, Geo_Prob, Ergodic, Price_Prob, Beta, nCat, nP, nc, Nstar )
% script created by Colette Marais 13/09/2013

% description
% ~~~~~~~~~~~
% SOLVE_MODEL Determines the firm's policy function using dynamic
% programming

% Input Arguments:
%
%       utility_mine    : The mine's utility
%       StateSpace      : Combination of all states
%       V               : Initial value function guess
%       Prob0           : Initial guess for the policy function
%       diffEV1         : Initial value for the policy difference if the
%                         firm remains in the pit
%       diffEV1         : Initial value for the policy difference if the
%                         firm leaves the pit
%       Geo_Prob        : Geological transition probabilities
%       Ergodic         : Ergodic category probabilities
%       Price_Prob      : Price probabilities
%       Beta            : Discount factor
%       nCat            : Number of ore categories
%       nP              : Number of price states
%       nc              : Number of cost levels
%       Nstar           : Number of elements in state space
%
%
% Output Arguments:
%
%       V               : The firm's value function
%       Prob0           : The firm's policy function
%       Count           : Number of iterations to solve
%


%% Definitions

I = speye(Nstar,Nstar);                                                    % Identity Matrix
n_trans = nCat*nP;                                                         % Number of transitions
trans_x = zeros(Nstar*n_trans,1);                                          % Store of x transitions
trans_y0 = zeros(Nstar*n_trans,1);                                         % Store of y transitions
trans_prob0 = zeros(Nstar*n_trans,1);                                      % Store of transition probabilities
trans_y1 = zeros(Nstar*n_trans,1);                                         % Store of y transitions
trans_prob1 = zeros(Nstar*n_trans,1);                                      % Store of transition probabilities
next_prob = zeros(nCat*nP,nP);                                             % Store of possible next pit transition probabilities
current_prob = zeros(n_trans,n_trans*nCat);                                % Store of possible current pit transition probabilities
EV = zeros(size(utility_mine));                                            % Store of expected value function
next_loc = zeros(nCat*nP,1);                                               % Store of next locations (in the next pit)
temp = zeros(nP*nc,1);

Price_Index = zeros(Nstar/(nCat*nCat),1);                                  % Store of price index
for i = 1:nP
    Price_Index(i*nc-nc+1:i*nc) = i*ones(nc,1);
end
Price_Index = repmat(Price_Index,nCat*nCat,1);

count = 0;                                                                 % Initialise count

%% Probabilities

% For next pit

for i = 1:nCat                                                             % Loop through ore categories
    for j = 1:nP                                                           % Loop through possible prices
        next_prob(i*nP-nP+1:i*nP,j) = Ergodic(i)*Price_Prob(j,:);          % Each column in next_prob represents the probabilities of moving to all combinations of the ore and price categories given in current price category j (column number)
    end
    next_loc(i*nP-nP+1:i*nP) = (i-1)*Nstar/nCat+1+(i-1)*nP*nc:nc:(i-1)*Nstar/(nCat)+(i*nP-1)*nc+1;    % Find the next period location
end

% For the current pit

for m = 1:nCat*nCat                                                        % Loop through ore categories
    for n = 1:nP                                                           % Loop through possible prices
        index_M = (m-1)*nP + n;                                            % Create an index of the current state (all possible combinations of ore and price categories)
        for j = 1:nCat                                                     % Loop through ore categories
            for k = 1:nP                                                   % Loop through possible prices
                index = (j-1)*nP+k;                                        % Create an index of the next state (all possible combinations of ore and price categories)
                current_prob(index,index_M) = Geo_Prob(m,j)*Price_Prob(n,k); % Each column in next_prob represents the probabilities of moving to all combinations of the ore and price categories given in current ore and price categories
            end
        end
    end
end

%% Solve the Model

% Determine the next period transitions if the firm stays in the pit

for i = 1:Nstar
        
        % Determine the x-coordinate of the next period transition
    
        trans_x(i*n_trans-n_trans+1:i*n_trans) = repmat(i,n_trans,1);
        
        % Determine the y-coordinate if the firm remains in the current pit
        
        for j = 1:nCat
            
            trans_y0(i*n_trans - n_trans+1+(j-1)*nP:i*n_trans-n_trans+j*nP) = i-(Price_Index(i)-1)*nc-(StateSpace(i,1)-j)*nP*nCat*nc:nc:i-(Price_Index(i)-1)*nc-(StateSpace(i,1)-j)*nP*nCat*nc+(nP-1)*nc;
            
        end
        
        % Determine the probability of all moves withing the pit
        
        trans_prob0(i*n_trans - n_trans+1:i*n_trans) = current_prob(:,(nCat*StateSpace(i,1)-nCat+StateSpace(i,2)-1)*nP+Price_Index(i))';
        
        % Determine the y-coordinate if the firm moves  to the next pit
        
        trans_y1(i*n_trans - n_trans + 1:i*n_trans) = next_loc;
        
        % Determine the probability of all moves to the next pit
        
        trans_prob1(i*n_trans-n_trans+1:i*n_trans) = next_prob(:,Price_Index(i));
end
   
% Define the sparse tarnsition matrices

 Trans0 = sparse(trans_x,trans_y0,trans_prob0);                            % The firm stays in the pit
 Trans1 = sparse(trans_x,trans_y1,trans_prob1);                            % The firm moves to a new pit

 %% Solve the Dynamic Programme

while (diffEV1 > 1e-6 && diffEV2 > 1e-6)
    count = count+1;
    
    % Vind V*
    
    Vstar0 = ((I - Beta*Trans0)\utility_mine(:,1)).*Prob0;
    Vstar1 = ((I - Beta*Trans1)\utility_mine(:,2)).*(1-Prob0);
    
    % Find the expected value function
    
    for i = 1:Nstar
        
        for j = 1:nCat
            trans_y1(i*n_trans - n_trans+1+(j-1)*nP:i*n_trans-n_trans+j*nP) = i-(Price_Index(i)-1)*nc-(StateSpace(i,1)-j)*nP*nCat*nc:nc:i-(Price_Index(i)-1)*nc-(StateSpace(i,1)-j)*nP*nCat*nc+(nP-1)*nc;
        end
        
        EV(i,1) = current_prob(:,(StateSpace(i,1)*StateSpace(i,2)-1)*nP+Price_Index(i))'*(log(exp(Vstar0(trans_y1(i*n_trans - n_trans + 1:i*n_trans))) + exp(Vstar1(next_loc))));
        
        EV(i,2) = next_prob(:,Price_Index(i))'*(log(exp(Vstar0(trans_y1(i*n_trans - n_trans + 1:i*n_trans))) + exp(Vstar1(next_loc))));   
        
    end
    
    % Determine the updated value function
    
    newV = utility_mine + EV;
    
    diffEV1 = sum((newV(:,1) - V(:,1)).^2);                                % Find the difference between the new and old value functions
    
    diffEV2 = sum((newV(:,2) - V(:,2)).^2);                                % Find the difference between the new and old value functions
    
    V = newV;
    
    % Determine the updated probabilities
    
    for i = 1:nP
        temp((i-1)*nc+1:i*nc) = repmat(V((i-1)*nc+1,2),nc,1);
    end
    
    
    VProb = repmat(temp,Nstar/(nP*nc),1);
    
    Prob0 = exp(newV(:,1))./(exp(newV(:,1))+exp(VProb));
    
end



end

