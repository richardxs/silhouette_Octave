function [si, h] = silhouette(X, clust, metric)

% Nan Zhou
% Code Matlab 'silhouette' into Octave function
% Sichuan University, Macquarie University
% zhnanx@gmail.com

% input parameters
% X, n-by-p data matrix
% - Rows of X correspond to points, columns correspond to coordinates. 
% clust, clusters defined for X; n-by-1 vector
% metric, e.g. Euclidean, sqEuclidean, cosine


% return values
% si, silhouettte values, n-by-1 vector
% h, figure handle, waiting to be solved in the future

% algorithm reference
% - Peter J. Rousseeuw (1987)
% - Silhouettes: a Graphical Aid to the Interpretation and Validation of Cluster Analysis
% - doi:10.1016/0377-0427(87)90125-7

  % check size
  if (size(X, 1) != size(clust, 1))
    error("First dimension of X <%d> doesn't match that of clust <%d>",...
      size(X, 1), size(clust, 1));
  endif
  
  % check metric
  if (! exist('metric', 'var'))
    metric = 'sqEuclidean';
  endif
  
  %%%% function set
  function [dist] = EuclideanDist(x, y)
    dist = sqrt((x - y) * (x - y)');
  endfunction
  
  function [dist] = sqEuclideanDist(x, y)
    dist = (x - y) * (x - y)';
  endfunction
  
  function [dist] = cosineDist(x, y)
    cosineValue = dot(x,y)/(norm(x,2)*norm(y,2));
    dist = 1 - cosineValue;
  endfunction
  %%% end function set

  % calculating
  si = zeros(size(X, 1), 1);
  %h
  
  %calculate values of si one by one
  for iii = 1:length(si)
    
    %%% distance of iii to all others
    iii2all = zeros(size(X, 1), 1);
    for jjj = 1:size(X, 1)
        switch (metric)
          case 'Euclidean'
            iii2all(jjj) = EuclideanDist(X(iii, :), X(jjj, :));
          case 'sqEuclidean'
            iii2all(jjj) = sqEuclideanDist(X(iii, :), X(jjj, :));
          case 'cosine'
            iii2all(jjj) = cosineDist(X(iii, :), X(jjj, :));
          otherwise
            error('Invalid metric.');
        endswitch
    endfor
    %%% end distance to all
    
    %%% allocate values to clusters
    clusterIDs = unique(clust); % eg [1; 2; 3; 4]
    groupedValues = {};
    for jjj = 1:length(clusterIDs)
      groupedValues{clusterIDs(jjj)} = [iii2all(clust == clusterIDs(jjj))];
    endfor
    %%% end allocation
    
    
    %%% calculate a(i)
    % dist of object iii to all other objects in the same cluster
    a_iii = groupedValues{clust(iii)};
    % average distance of iii to all other objects in the same cluster
    a_i = sum(a_iii) / (size(a_iii, 1) - 1);
    %disp(a_i);pause;
    %%% end a(i)
    
    
    %%% calculate b(i)
    clusterIDs_new = clusterIDs;
    % remove the cluster iii in
    clusterIDs_new(find(clusterIDs_new == clust(iii))) = [];
    % average distance of iii to all objects of another cluster
    a_iii_2others = zeros(length(clusterIDs_new), 1);
    for jjj = 1:length(clusterIDs_new)
      values_another = groupedValues{clusterIDs_new(jjj)};
      a_iii_2others(jjj) = mean(values_another);
    endfor
    b_i = min(a_iii_2others);
    %disp(b_i);disp('---');pause;
    %%% end b(i)
    
    
    %%% calculate s(i)
    si(iii) = (b_i - a_i) / max([a_i; b_i]);
    %%% end s(i)
    
  endfor
  
end
