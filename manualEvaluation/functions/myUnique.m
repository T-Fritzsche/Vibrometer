function y = myUnique(x)
  y = unique(x);
  y(isnan(y(1:end))) = [];
end