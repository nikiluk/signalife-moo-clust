% test m=all_comb(alphabet,n);
%
% 'alphabet' is an array of L element.n is a positive integer representing
% the number of places in which the elements of 'alphabet' are arranged.
% m=all_comb(alphabet,n) returns an (L^n X n) matrix of all possible 
% n-digit combinations of the elements of a given L-element alphabet.
% This function is very useful in finding all possible n-digit numbers 
% that may be constructed from a set of digits; and when char(m) is used, 
% all possible n-letter words that may constructed from a group of letters 
% is found by this function. 
%
% By: Abdulrahman Ikram Siddiq
% Kirkuk - IRAQ
% Thursday Oct.27th 2011 11:20 PM

clear
clc

% To generate all possible 4-letter words from the given alphabet
alphabet=['a' 'n' 'd'];
n=4; % number of letters in each output word
char(all_comb(alphabet,n))

% To generate all possible 5-bit binary codes
alphabet=[0 1];
n=5; % number of bits per code
m=all_comb(alphabet,n)

% To generate all possible 3-digit numbers from the digits 1,3,4,7,and 8
alphabet=[1 3 4 7 8];
n=3; % number of bits per code
m=all_comb(alphabet,n)