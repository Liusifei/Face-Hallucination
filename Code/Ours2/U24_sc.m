%Chih-Yuan Yang
%10/11/12
%Usage
%U24_sc(img,[0 1]);
function hfig = U24_sc(varargin)
    bSetColormapGray = false;
    for j=1:nargin
        if isa(varargin{j},'char')
            ControlString = varargin{j};
            StringLength = length(ControlString);
            for i=1:StringLength
                switch ControlString(i)
                    case 'c'
                        close all
                    case 'g'
                        bSetColormapGray = true;
                    otherwise
                end
            end
        end
        
        [h w] = size(varargin{j});
        if h == 1 && w == 2 && ~isa(varargin{j},'char')
            caxis_min_high = varargin{j};
        end
    end
    
    for i=1:nargin
        if ~isa(varargin{i},'char')
            [h w] = size(varargin{i});
            if ~(h==1 && w==2)
                layer = size(varargin{i},3);
                for j=1:layer
                    hfig = figure;
                    imagesc(varargin{i}(:,:,j));
                    colorbar
                    axis image
                    axis on
                    if layer == 1
                        string = inputname(i);
                    else
                        string = sprintf('%s %d',inputname(i), j);
                    end
                    TitleString = regexprep(string,'\_','\\_');
                    title(TitleString);
                    set(hfig,'Name',string,'NumberTitle','off');
                    
                    if bSetColormapGray
                        colormap gray
                    end
                    if exist('caxis_min_high','var')
                        caxis(caxis_min_high);
                    end
                end
            end
        end
    end
end