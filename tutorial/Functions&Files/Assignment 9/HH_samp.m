function samp = HH_samp(vect,nSamps)
%   samp = HH_samp(vect,nSamps)
%   
%   HH_samp returns a random subset of size nSamps of the vector vect. For
%   example, HH_samp([1:10],4) might return [1 4 7 2]. Entries are selected
%   without replacement and returned unsorted. If vect is a 2D matrix,
%   HH_samp returns a random subset of the rows in the matrix (without
%   replacement). If nSamps>max(size(vect)), HH_samp returns an empty
%   matrix.

if nSamps>max(size(vect))
    samp=[];
    return
elseif size(vect,1)==1 %vect is a row vector
    ind=randperm(size(vect,2));    
    ind=ind(1:nSamps);
    samp=vect(ind);
else %size is a matrix or a column vector
    ind=randperm(size(vect,1));    
    ind=ind(1:nSamps);
    samp=vect(ind,:);
end