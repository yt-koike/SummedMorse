[v,fs] = audioread("f593.8.wav");
tic
message = audio2morse(v,256,128);
display(message);

% Translate to English
result_EN = morse_decode(message,"EN");
toc
display(result_EN);
% Translate to Japanese
result_JP = morse_decode(message,"JP");
display(result_JP);

function message = audio2morse(morse_v,framelength,noverlap)
en = sum(morse_v(frameindex(framelength,noverlap,length(morse_v))).^2);
fix_en = zeros(size(en));
fix_en(en>max(en)/2) = 1;
on = find(islocalmax(diff(fix_en),'FlatSelection', 'first'));
off = find(islocalmin(diff(fix_en),'FlatSelection', 'first'));
sw_duration=zeros(1,length(off)*2+1);
sw_duration(1:2:end)=[off length(en)]-[1 on];
sw_duration(2:2:end)=off-on;
dot_duration = min(abs(sw_duration));
word_gap_duration = 7 * dot_duration;
% normalize by the duration of the words' gap
sw_duration_N = sw_duration/word_gap_duration;
% if it's not enough, normalize by the amplitude
if max(abs(sw_duration_N)) > 1
    sw_duration_N = sw_duration_N/max(abs(sw_duration_N));
end
%plot(en);title("Energy");xlabel("Frame Index");
%figure;plot(fix_en);ylim([0 2]);title("On-Off switch");xlabel("Frame Index");
%figure;plot(sw_duration_N);title("Normalized switch duration");
message = '';
for x = sw_duration_N
    if bitand(x > 0, x < 0.25)
        message = [message '.'];
    end
    if x >= 0.25
        message = [message '-'];
    end
    if bitand(-0.8<x, x < -0.3)
        message = [message ' '];
    end
    if x<-0.8
        message = [message '   '];
    end
end
end

function result = morse_decode(morseStr,language)
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
result = "";
words = [];
for wordCode = split(morseStr,'   ')'
    word = "";
    for letterCode = split(wordCode)'
        idx = find(letterCode == codes);
        if length(idx) == 1
            word = word + letters(idx);
        end
    end
    words = [words word];
end
result = join(words);
end

function findex = frameindex(framelength, noverlap, signallength)
nshift = framelength-noverlap;
n = fix((signallength-framelength)/nshift+1);
findex=(1:framelength)'+(0:n-1)*nshift;
end