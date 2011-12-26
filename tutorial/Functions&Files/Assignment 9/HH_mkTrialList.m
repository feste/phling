function [TrialList]=HH_mkTrialList(conds,reps);
%HH_mkTrialList
%takes a cell of conditions and the number of trials per condition
%combination and returns a triallist
% example: conds={[1 2 3] [0 1] [2 4 6]};
% TrialList=HH_mkTrialList(conds,10);

if ~iscell(conds)
    disp('first parameter must be a cell array')
    return
end

nConds=length(conds);

for i=1:nConds
    temp=conds{i};
    if size(temp,1)==1
        temp=temp';
    end

    if i==1
        total=temp;
    else
        total=[repmat(total,length(temp),1) Expand(temp,1,size(total,1))];
    end
end

TrialList=repmat(total,reps,1);
TrialList=TrialList(randperm(length(TrialList)),:);