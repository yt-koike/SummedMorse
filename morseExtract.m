[v,fs] = audioread("morse.wav");
framelength = 512; noverlap = 256;
graphRow = 3;
tic
freqs = freq_detect(v,fs,framelength,noverlap);
if ~isempty(freqs)
    t = (0:length(v)-1)/fs;
    for i = 1:length(freqs)
        f = freqs(i);
        BPF = fir1(256, [f-1 f+1]/(fs/2));
        vf = filter(BPF, 1, v);
        vf(abs(vf)<0.2) = 0;
        nonVoidIdx = find(vf~=0,1):find(vf~=0,1,'last');
        vfr = vf(nonVoidIdx);
        vfr = vfr / max(abs(vfr));
        if mod(i-1,graphRow) == 0
            figure
        end
        subplot(graphRow,1,mod(i-1,graphRow)+1);
        plot(t(1:length(vfr)),vfr);
        title(sprintf("%.1f Hz",f));
        if length(vfr)>0
        audiowrite(sprintf("f%.1f.wav",f),vfr,fs);
        end
    end
end
toc
function findex = frameindex(framelength, noverlap, signallength)
nshift = framelength-noverlap;
n = fix((signallength-framelength)/nshift+1);
findex=(1:framelength)'+(0:n-1)*nshift;
end

function freqs = freq_detect(v,fs,framelen,noverlap)
yframe = v(frameindex(framelen ,noverlap,length(v)));
[flen,nframe] = size(yframe);
f = linspace(0,fs/2,flen/2+1);
freqs = [];
for i = 1:nframe
    sp = log(abs(fft(yframe(:,i).*hann(flen))));
    spr = sp(1:length(sp)/2+1);
    [ispeak,prom] = islocalmax(spr,'MinProminence',10);
    freqs = union(freqs,f(find(ispeak)));
end
end
