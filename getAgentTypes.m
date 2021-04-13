function classes = getAgentTypes(inputVec)
% Returns the class of agent
% 
% Test
% getAgentTypes(1:57)

num1 = 50;
num2 = 5;

type1s = inputVec <= num1;
type2s = inputVec > num1 & inputVec <= (num1 + num2);
type3s = inputVec > (num1 + num2);

classes = 1*type1s + 2*type2s + 3*type3s;