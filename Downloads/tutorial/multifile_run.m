for i = 1:4
    
    switch i
        
        case 1
        str='6percent-ctrl-1.txt';%Users/Me/Desktop/tutorial/6percent-ctrl-1/
        %path='/Users/Me/Desktop/tutorial/6percent-ctrl-1/';
        path='/Users/robertnims/Downloads/tutorial/6percent-ctrl-1/';
        case 2
        str='6percent-ctrl-2.txt';%/Users/Me/Desktop/tutorial/6percent-ctrl-2/
        %path='/Users/Me/Desktop/tutorial/6percent-ctrl-2/';
        path='/Users/robertnims/Downloads/tutorial/6percent-ctrl-2/';
        case 3
        str='6percent-ctrl-3.txt';%/Users/Me/Desktop/tutorial/6percent-ctrl-2/
        %path='/Users/Me/Desktop/tutorial/6percent-ctrl-3/';
        path='/Users/robertnims/Downloads/tutorial/6percent-ctrl-3/';
        case 4
        str='6percent-ctrl-4.txt';%/Users/Me/Desktop/tutorial/6percent-ctrl-2/
        %path='/Users/Me/Desktop/tutorial/6percent-ctrl-4/';
        path='/Users/robertnims/Downloads/tutorial/6percent-ctrl-4/';
      
    end
    
    fprintf('This is file number ',num2str(i))
    optimizer2_newformat(str,path)
    figure
    
end


     
     