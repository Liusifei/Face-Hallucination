% testmain.m
clc
clear all
close all
a = rgb2gray(imread('a.png'));
b = rgb2gray(imread('b.png'));
b = b(1:size(a,1),1:size(a,2));
[D_best,ann] = PatchMatch(a,b);