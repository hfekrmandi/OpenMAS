%% DEMOPOLYNOM  Short demo of the polynom toolbox
%
%%

format compact short
setround(0)                           % set rounding to nearest    
    
%% Definition of a univariate polynomial
% The simplest way to generate a univariate polynomial is (like in Matlab) by
        
p = polynom([1 -3 0 4])
        
%%
% It generates a polynomial (of the INTLAB data type "polynom") with 
% coefficients 1, -3, 0 and 4. Note that the coefficient 
% corresponding to the highest exponent is specified first, and that the default dependent
% variable is "x". Another variable can be specified explicitly, e.g. by 
       
q = polynom([1 0 -2],'y')

%% Access to coefficients, exponents and variables I
% There is direct access to the vector of polynomial coefficients (starting with 
% the largest exponent), the vector of exponents and the independent variable in use:

coeff = q.c
expon = q.e
vars = q.v

%%
% The polynomial may also be specified by the individual coefficients and exponents. The 
% polynomial p, for example, is also generated as follows:
       
polynom([1 -3 4],[3 2 0])

%% Definition of a multivariate polynomial
% A multivariate polynomial is generated by specifying coefficients and corresponding 
% exponents. An example is 

P = polynom([-3 4 9],[2 3;4 0;2 2],{'a' 'b'})
        
%% Random polynomials
% A multivariate polynomial may generated randomly by
 
Q = randpoly(4,2)
        
%%
% where the first parameter specifies the degree and the second the number of variables.
% Note that the variables are "x1", "x2", ... by default. This may be changed by specifying
% other variable names explicitly:
        
QQ = randpoly(4,2,{'var1' 'var2'}) 

%% Access to coefficients, exponents and variables II
% As before there is also direct access to the polynomial coefficients, the exponents 
% and the independent variables for multivariate polynomials:

coeff = QQ.c
expon = QQ.e
vars = QQ.v

     
%% Display of polynomials
% Univariate polynomials may be displayed in dense or sparse mode, for example

polynominit('DisplayUPolyVector'),  p

%%

polynominit('DisplayUPolySparse'),  p
       
%% Operations between polynomials
% Operations between univariate polynomials are as usual
       
p, 3*p+1
       
%%
% and may produce multivariate polynomials if not depending on the same variable:
     
q, p+q
      
%% Interval polynomials 
% Interval polynomials are specified in the same way as before. Consider, for example (taken from 
% Hansen/Walster: Sharp Bounds for Interval Polynomial Roots, Reliable Computing 8(2) 2002)
      
format infsup
r = polynom([infsup(1,2) infsup(-4,2) infsup(-3,1)])
      
%%
% The polynomial may be displayed using other interval formats, for example
        
format midrad
r
       
%% Plot of polynomials
% The following plots the lower and upper bound polynomial within root bounds:
       
plotpoly(r)
      
%%
% or within specified bounds:
       
plotpoly(r,-2,2)
      
%% Access of coefficients I
% In contrast to Matlab, coefficients of INTLAB polynomials are set and accessed as in mathematics: 
       
q = p+1
coeff3 = q(3)
q(0) = -2
q(0:2) = 4.7 
     
%% Access of coefficients II
% Access of coefficients for multivariate polynomials works the same way by specifying
% the position for the individual variables:
       
P = polynom([-3 4 9],[2 3;4 0;2 2],{'a' 'b'})
coeff23 = P(2,3)
P(1,4) = -9

%% Subpolynomials
% Subpolynomials may be accessed by specifying certain unknowns as []. This corresponds
% to a distributive representation of the polynomial:

P
Q = P(2,[])  
        
%% Polynomial evaluation
% There are two (equivalent) possibilities of polynomial evaluation, by polyval or by {}:

p = polynom([1 -3 0 4])
polyval(p,2)
p{2}

%% Interval polynomial evaluation
% Of course, verified bounds are obtained in the well known ways:
        
polyval(intval(p),2)
p{intval(2)}
        
%%
% Polynomial evaluation for multivariate polynomials works the same way:
      
P = polynom([-3 4 9],[2 3;4 0;2 2],{'a' 'b'})
polyval(P,2,3)
P{2,intval(3)}
     
%% Evaluation of subpolynomials
% In addition, evaluation of sub- (or coefficient-) polynomials is possible by specifying
% certain unknowns as []. Unknowns specified by [] are still treated as independent variables.
% In this case the argument list must be one cell array:
     
polyval(P,{2,[]})
P{{[],intval(3)}}
        
%% Derivatives of polynomials
% First and higher polynomial derivatives are calculated by
        
p
p'
pderiv(p,2)
        
%%
% or, for multivariate polynomials, by specifiying the variable:
         
P = polynom([-3 4 9],[2 3;4 0;2 2],{'a' 'b'})
pderiv(P,'a')
pderiv(P,'b',2)

%% Bernstein polynomials
% A simple application is the computation of Bernstein coefficients. Consider 
     
P = polynom([2 -3 0 3 1 -2])
  
%%
% Suppose, we wish to expand the polynomial in the interval [-1,1]. Since Bernstein coefficients B_i
% are calculated with respect to [0,1], we first transform the polynomial:
       
Q = ptrans(P,-1,1,0,1); 
B = bernsteincoeff(Q)
 
%%
% For convenient use, the Bernstein coefficients are stored in a polynomial such that B(i) 
% is the i-th Bernstein coefficient for i=0:n. 

%% Polynomial evaluation and Bernstein polynomials
% The convex hull of 
% Bernstein points B contains the convex hull of the polynomial:
        
plotpoly(P,-1,1); 
hold on
plotbernstein(B,-1,1)
hold off
  
        
%% 
% This picture is not untypical. The Bernstein points overestimate the true range, 
% but sometimes not too much. To obtain a true inclusion of the range, we perform 
% the computation with verified bounds:    

format infsup
Q = ptrans(intval(P),-1,1,0,1); 
B = bernsteincoeff(Q), 
X = P{infsup(-1,1)}, 
Y = infsup(min(B.c.inf),max(B.c.sup))
       
%%
% From the picture we read the true range [-5,1] which is slightly overestimated by Y computed by
% the Bernstein approach. The same principle can be applied to multivariate polynomials.
    

%% Inclusion of roots of polynomials
% Roots of a univariate polynomial can approximated and included. 
% Consider a polynomial with roots 1,2,...,7:
     
format long
p = polynom(poly(1:7))
roots(p)                  % approximations of the roots
       
%%
% Based on some approximation (in this case near 4.1), verified bounds for a root are obtained by
       
verifypoly(p,4.1)
       
%%
% Note that the accuracy of the bounds is of the order of the (usually unknown) 
% sensitivity of the root.
      
%% Inclusion of clustered or multiple roots of polynomials
% The routine "verifypoly" calculates verified bounds for multiple roots as well.
% Consider the polynomial with three 4-fold roots at x=1, x=2 and x=3:
             
format short midrad
p = polynom(poly([1 1 1 1 2 2 2 2 3 3 3 3])); roots(p)

%%
% Based on some approximation (in this case 2.001), verified bounds for a multiple root are obtained by
     
verifypoly(p,2.001)
  
%%
% Note that the accuracy of the bounds is of the order of the sensitivity of the root, i.e. of the order
% eps^(1/4) = 1.2e-4. The multiplicity of the root is determined as well (for details, see "verifypoly").
     
[X,k] = verifypoly(p,2.999)

%% Quality of the computed bounds 
% One may argue that the previous inclusion is rather broad. But look at the graph of the polynomial near x=3:
    
p = polynom(poly([1 1 1 1 2 2 2 2 3 3 3 3]));
plotpoly(p,2.99,3.01)
title('Floating point evaluation of p near x=3')
 
%% Quality of the computed bounds for coefficients with tolerances
% Due to rounding and cancellation errors the accuracy of the inclusion is about optimal. Things are
% even more drastic when the polynomial coefficients are afflicted with tolerances. Put smallest possible
% intervals around the coefficients of p and look at the graph.
% Between about 2.993 and 3.007 the lower and upper bound enclose zero.
       
P = polynom(midrad(p.c,1e-16));  
plotpoly(P,2.99,3.01)
title('Interval polynomial P near x=3')

%% Sylvester matrix
% The Sylvester matrix of two polynomials p,q is singular iff p and q have a root in common. 
% Therefore, the Sylvester matrix of p and p' may determine whether p has multiple roots.
% Note, however, that this test is not numerically stable.

format short
p = polynom(poly([2-3i 2-3i randn(1,3)]))       % polynomial with double root 2-3i
roots(p)
S = sylvester(p);         % Sylvester matrix of p and p'
format short e
svd(S)

%% Predefined polynomials
% There are a number of predefined polynomials such as Chebyshev, Gegenbauer, Hermite polynomials etc. 

%% Enjoy INTLAB
% INTLAB was designed and written by S.M. Rump, head of the Institute for Reliable Computing,
% Hamburg University of Technology. Suggestions are always welcome to rump (at) tuhh.de
