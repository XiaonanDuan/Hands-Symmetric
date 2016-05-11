function conf = sigmoid(C1, C2)
	para = log(9) / 10000;
	Dis = sum((C1 - C2).^2);
	conf = 1 / (1 + exp(para * Dis));
end
