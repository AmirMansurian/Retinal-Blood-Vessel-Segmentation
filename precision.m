function out = precision (Original, Result, Mask)

[row, col] = size (Original);

out = uint32(zeros(4, 1));

for i=1: 1: row
    for j=1: 1: col
        
        if Mask(i, j) == 255
            if Original(i, j) == 255 && Result(i, j) == 255
                out(1) = out(1) + 1;
            elseif Original(i, j) == 0 && Result(i, j) == 0
                out(2) = out(2) + 1;
            elseif Original(i, j) == 0 && Result(i, j) ~=0
                out(3) = out(3) + 1;
            elseif Original(i, j) == 255 && Result(i, j) ~= 255 
                out(4) = out(4) + 1;
            end
        end
        
        
    end
end
end