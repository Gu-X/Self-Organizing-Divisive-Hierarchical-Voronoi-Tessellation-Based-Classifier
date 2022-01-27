clear all
clc
close all


load exampledata
% DTra1: training data
% DTes1: unlabelled testing data
% LTra1: labels of training data
% LTes1: labels of testing data

[Estlabels,systemparameter,texe]=DHT(DTra1,LTra1,DTes1); % run the DHT algorithm
% Estlabels: predicted labels of testing data
% systemparameter: learned model from training data
% texe: the training time consumption

cmat=confusionmat(LTes1,Estlabels);  % Confuison matrix

Acc=sum(sum(cmat.*eye(size(cmat,1))))/sum(sum(cmat)); % Classifictaion accuracy on testing data
