function strInfo = getAgentLinkInfo(srcNodes, destNodes)
% Returns strings capturing the type of node for each
% and the type of the link
% 
% Test
% srcNodes = [1 2 3 51 52 56]';
% destNodes = [2 53 57 52 57 57]';
% strInfo = getAgentLinkInfo(srcNodes, destNodes)

numIn = numel(srcNodes);
if numIn ~= numel(destNodes)
    error("Input dims don't match %d != %d\n", numIn, numel(destNodes));
end


srcTypes = getAgentTypes(srcNodes(:));
destTypes = getAgentTypes(destNodes(:));
linkTypes = max(srcTypes, destTypes);

srcTypeStr = appendStrs('Agent', srcTypes);
destTypeStr = appendStrs('Agent', destTypes);
linkTypesStr = appendStrs('Network', linkTypes);

strInfo = [srcTypeStr, destTypeStr, linkTypesStr];