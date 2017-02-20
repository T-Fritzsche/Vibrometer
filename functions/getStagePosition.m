function[posx,posy,posz]=getStagePosition( serial )
% returns the current position of the x-y-stage

posz = inf; posy = posz; posx= posy;

%remove dummy values
flushinput(serial);
sAxisReturn = query(serial,'POS?');

if (~isempty(sAxisReturn))
    pat = '([0-9\.]*),?';
    tok = regexp(sAxisReturn, pat, 'tokens');
    posx = str2double(tok{1,1}{1,1});
    posy = str2double(tok{1,2}{1,1});
    posz = str2double(tok{1,3}{1,1});
end
