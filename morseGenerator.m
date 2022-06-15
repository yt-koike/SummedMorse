fs = 8000;
% Content, Language, Wave freqency, duration of dits (Unit: seconds), offset
%settings = ["sos","EN",700,0.1,1];
%{
settings = [
    "a","EN",600,0.1,1; ...
    "b","EN",700,0.1,1; ...
    "c","EN",800,0.1,1; ...
    ];
%}
%%{
settings = [
    "what hath god wrought","EN",600,0.1,1; ...
    "hello world","EN",700,0.1,1; ...
    "morse code","EN",800,0.1,1; ...
    ];
%%}
%{
settings = [
    "what hath god wrought","EN",600,0.3,10000; ...
    "hello world","EN",700,0.15,5000; ...
    "morse code","EN",800,0.2,1; ...
    ];
%}
v = morse_gen(fs,settings);
v = v/max(abs(v));
t = (0:length(v)-1)/fs;
plot(t,v);
xlabel("time(s)");
title("morse signal");
audiowrite("morse.wav",v,fs);

function v = merge_wave(v,wave,offset)
if length(v) < length(wave) + offset
    v = [v zeros(1,length(wave)+offset-length(v))];
end
range = offset+(1:length(wave))-1;
v(range) = v(range) + wave;
end

function result = morse_encode(string,language)
if language == "EN"
    letters = 'abcdefghijklmnopqrstuvwxyz';
    codes = [".-","-...","-.-." ...
        ,"-..",".","..-." ...
        ,"--.","....","..",".---" ...
        ,"-.-",".-..","--" ...
        ,"-.","---",".--." ...
        ,"--.-",".-.","...","-" ...
        ,"..-","...-",".--" ...
        ,"-..-","-.--","--.."];
end
if language == "JP"
    letters = 'アイウエオ';
    codes = ["--.--",".-","..-", "-.---",".-..."];
    letters = [letters 'カキクケコ'];
    codes = [codes,".-..","-.-..","...-","-.--","----"];
    letters = [letters 'サシスセソ'];
    codes = [codes,"-.-.-","--.-.","---.-",".---.","---."];
    letters = [letters 'タチツテト'];
    codes = [codes,"-.","..-.",".--.",".-.--","..-.."];
    letters = [letters 'ナニヌネノ'];
    codes = [codes,".-.","-.-.","....","--.-","..--"];
    letters = [letters 'ハヒフヘホ'];
    codes = [codes,"-...","--..-","--..",".","-.."];
    letters = [letters 'マミムメモ'];
    codes = [codes,"-..-","..-.-","-","-...-","-..-."];
    letters = [letters 'ヤユヨ'];
    codes = [codes,".--","-..--","--"];
    letters = [letters 'ラリルレロ'];
    codes = [codes,"...","--.","-.--.","---",".-.-"];
    letters = [letters 'ワヲン'];
    codes = [codes,"-.-",".---",".-.-."];
end
letters = [letters,' ']; codes = [codes," "];
result = '';
for letter = convertStringsToChars(string)
    idx = find(letter == letters);
    if length(idx) == 1
        result = result + codes(idx) + " ";
    end
end
end

function v = morse_sound(code,f,dit_duration,fs)
v = [];
t1 = 0:1/fs:dit_duration-1/fs;
dot = sin(2*pi*f*t1);
t3 = 0:1/fs:3*dit_duration-1/fs;
dash = sin(2*pi*f*t3);
nil = zeros(size(t1));
for x = convertStringsToChars(code)
    if x == '.'
        v = [v dot];
    elseif x == '-'
        v = [v dash];
    elseif x == ' '
        v = [v nil];
    end
    v = [v nil];
end
end

function v = morse_gen(fs,settings)
v = [];
for i = 1:size(settings,1)
    setting = settings(i,:);
    string = setting(1);
    language = setting(2);
    f = str2num(setting(3));
    dit_duration = str2num(setting(4));
    offset = str2num(setting(5));
    morse = morse_sound(morse_encode(string,language),f,dit_duration,fs);
    if isempty(v)
        v = morse;
    else
        v = merge_wave(v,morse,offset);
    end
end
end