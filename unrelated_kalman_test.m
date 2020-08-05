rng('default')

x_11 = [0; 1; 2; 3];
P_11 = 0.5*eye(4);
x_prior = [0; 1; 2; 3];
S_prior = 2*eye(4);
y_prior = S_prior*x_prior;

Q_i = 0.1*eye(2);
R_i = 0.1;
x_true = [3; 0; -1; 3];
F = eye(4);
Q = 0.1*eye(4);
R = 0.1*eye(2);

for i = 1:100
    %x_true = F*x_true + mvnrnd([0, 0, 0, 0], Q)';
    z_val = sqrt((x_true(3) - x_true(1))^2 + (x_true(4) - x_true(2))^2);
    z = [z_val; z_val] + mvnrnd([0, 0], R)';
    H = [(x_11(1) - x_11(3))/z(1), (x_11(2) - x_11(4))/z(1), ...
        (x_11(3) - x_11(1))/z(1), (x_11(4) - x_11(2))/z(1);...
        (x_11(1) - x_11(3))/z(2), (x_11(2) - x_11(4))/z(2),...
        (x_11(3) - x_11(1))/z(2), (x_11(4) - x_11(2))/z(2)];
    
    H_test = [(x_true(1) - x_true(3))/z_val, (x_true(2) - x_true(4))/z_val, ...
        (x_true(3) - x_true(1))/z_val, (x_true(4) - x_true(2))/z_val;...
        (x_true(1) - x_true(3))/z_val, (x_true(2) - x_true(4))/z_val,...
        (x_true(3) - x_true(1))/z_val, (x_true(4) - x_true(2))/z_val];
    SBZ = z - H_test*x_true;
    
    x_01 = F*x_11;
    P_01 = F*P_11*F' + Q;
    y = z - H*x_01;
    S = H*P_01*H' + R;
    K = P_01*H'*inv(S);
    x_00 = x_01 + K*y;
    P_00 = (eye(4) - K*H)*P_01;
    y = z - H*x_00;
    
    x_11 = x_00;
    P_11 = P_00;
end

% for i = 1:100
%     x_true = F*x_true + mvnrnd([0, 0, 0, 0], Q)';
%     z_val = sqrt((x_true(3) - x_true(1))^2 + (x_true(4) - x_true(2))^2);
%     z = [z_val; z_val] + mvnrnd([0, 0], R)';
%     H = [(x_prior(1) - x_prior(3))/z(1), (x_prior(2) - x_prior(4))/z(1), ...
%         (x_prior(3) - x_prior(1))/z(1), (x_prior(4) - x_prior(2))/z(1);...
%         (x_prior(1) - x_prior(3))/z(2), (x_prior(2) - x_prior(4))/z(2),...
%         (x_prior(3) - x_prior(1))/z(2), (x_prior(4) - x_prior(2))/z(2)];
%     y = z - H*x_01;
%     K = P_prior*H'*inv(H*P_prior*H'+R);
%     x = (eye(4) - K*H)*x_prior + K*z;
%     P = (eye(4) - K*H)*P_prior;
%     x_post = F*x;
%     P_post = Q + F*P*F';
%     
%     x_prior = x_post;
%     P_prior = P_post;
% end
