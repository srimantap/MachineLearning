function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% ====================== PART 1 ======================

% Add column of ones to X
Input_a_1 = [ones(m, 1) X];                    % size 5000 x 401
Hidden_z_2 = Input_a_1 * Theta1';              % size :  Theta1 25 x 401, Hidden_z_2 5000 x 25
Hidden_a_2 = [ones(m, 1) sigmoid(Hidden_z_2)]; % size Hidden_a_2 5000 x 26

Output_z_3 = Hidden_a_2 * Theta2';             % size :  Theta2 10 x 26, Hidden_z_3 5000 x 10
Output_a_3 = sigmoid(Output_z_3);              % size :  Hidden_a_3 5000 x 10
%disp(size(Output_a_3));

% Need to resize the y classification vector according to the labels
H_vector = zeros(m, num_labels);
for index = 1:m
  H_vector(index, y(index, 1)) = 1;
endfor

% Cost without regularization
square_error = (-H_vector .* log(Output_a_3)) .- ((1.0 .- H_vector) .* ...
                (log(1.0 .- Output_a_3)));
J = (1.0/m) * sum(sum(square_error, 2));

% ====================== PART 2 ======================


% size : delta_3 = 5000 x 10
delta_3 = Output_a_3 .- H_vector;

% size : delta_3 = 5000 x 10, Theta2 = 10 x 26, Hidden_z_2 = 5000 x 25
delta_2 = (delta_3 * Theta2(:, 2:end)) .* sigmoidGradient(Hidden_z_2);

Theta1_grad = (1/m) * (Theta1_grad .+ (delta_2' * Input_a_1));
Theta2_grad = (1/m) * (Theta2_grad .+ (delta_3' * Hidden_a_2));


% ====================== PART 3 ======================

% With regularization

% Regularization entities
Theta1_temp = Theta1;
Theta1_temp(:, 1) = 0;
Reg_theta1 = sum(sum(Theta1_temp .^ 2));

Theta2_temp = Theta2;
Theta2_temp(:, 1) = 0; 
Reg_theta2 = sum(sum(Theta2_temp .^ 2));

Reg_cost = (lambda /(2 * m)) * (Reg_theta1 + Reg_theta2);
Reg_theta1_grad = (lambda / m) * Theta1_temp;
Reg_theta2_grad = (lambda / m) * Theta2_temp;

% Cost with regularization
J = J + Reg_cost;

% Gradient regularization
Theta1_grad = Theta1_grad .+ Reg_theta1_grad;
Theta2_grad = Theta2_grad .+ Reg_theta2_grad;



% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
