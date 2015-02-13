function m=all_comb(alphabet,n);
% 'alphabet' is an array of L element.n is a positive integer representing
% the number of places in which the elements of 'alphabet' are arranged.
% m=all_comb(alphabet,n) returns an (L^n X n) matrix of all possible 
% n-digit combinations of the elements of a given L-element alphabet.
% This function is very useful in finding all possible n-digit numbers 
% that may be constructed from a set of digits; and when char(m) is used, 
% all possible n-letter words that may constructed from a group of letters 
% is found by this function. 
% NOTE THAT the transposition operation used in this function in line 35
% will change complex-valued entries to their complex conjugate. 
%
% By: Abdulrahman Ikram Siddiq
% Kirkuk - IRAQ
% Thursday Oct.27th 2011 11:15 PM

if nargin ~= 2
    error('Incorrect number of inputs')
end

if abs(round(n))~=n
        error('n must be a positive integer')
end

L=length(alphabet);
for i=n:-1:1
    v=[];
    for j=1:L
        v=[v alphabet(j)*ones(1,L^(i-1))];
    end
    cv=[];
    Lv=length(v);
    for k=1:(L^n)/Lv
        cv=[cv v];
    end
     m(1:L^n,n-i+1)=cv';
end