function [Estlabel,systemparameter,traintime]=DHT(tradata,tralabel,tesdata)
tic
TS=std(tradata);
seqts=find(TS~=0);
tradata=tradata(:,seqts);
%%
[tradata,J,~]=unique(tradata,'rows');
tralabel=tralabel(J);
[L,W]=size(tradata);
dist00=pdist(tradata./repmat(TS,L,1),'euclidean').^2./W;
dist0=squareform(dist00);
dist00=sort(dist00,'ascend');

averdist0=mean(dist00);
averdist=averdist0;

density=exp(-1*dist0/(averdist(end)));
temp1=zeros(L);
temp1(dist0<=averdist(end))=1;
density=density./repmat(sum(density,1),L,1);
density1=sum(density,2);
temp2=temp1.*repmat(density1',L,1);
[~,tempidx]=max(temp2,[],2);
tempseq=[1:1:L]';
centeridx=find([tempidx-tempseq]==0);
LC=length(centeridx);
centre={};
links={};
centrelabel={};
indi=zeros(LC,1);
centre{1}=zeros(LC,W);
centrelabel{1}=zeros(LC,1);
tempseq2=[];
for ii=1:1:LC
    centre{1}(ii,:)=tradata(centeridx(ii),:);
end
[~,PartIdx]=min(dist0(:,centeridx),[],2);
for ii=1:1:LC
    seq=find(PartIdx==ii);
    templ=unique(tralabel(seq));
    indi(ii)=length(templ)-1;
    if indi(ii)==0
        centrelabel{1}(ii)=unique(templ);
        tempseq2=[tempseq2;seq];
    else
        centrelabel{1}(ii)=NaN;
    end
end
dist0(tempseq2,:)=[];
dist0(:,tempseq2)=[];
tradata(tempseq2,:)=[];
tralabel(tempseq2)=[];
PartIdx(tempseq2)=[];
L=length(tralabel);
count=1;
while sum(indi)~=0
    count=count+1;
    links{count-1}=[];
    dist00(dist00>averdist0)=[];
    averdist0=mean(dist00);
    averdist(end+1,1)=averdist0;
    tempseq3=find(indi~=0);
    indi1=[];
    LC0=0;
    PartIdx0=zeros(L,1);
    centrelabel{count}=[];
    centre{count}=[];
    tempseq2=[];
    for ii=tempseq3'
        tempseq4=find(PartIdx==ii);
        data1=tradata(tempseq4,:);
        label1=tralabel(tempseq4,:);
        L1=length(tempseq4);
        dist1=dist0(tempseq4,:);
        dist1=dist1(:,tempseq4);
        density=exp(-1*dist1/(averdist(end)));
        temp1=zeros(L1);
        temp1(dist1<=averdist(end))=1;
        density=density./repmat(sum(density,1),L1,1);
        density1=sum(density,2);
        temp2=temp1.*repmat(density1',L1,1);
        [~,tempidx]=max(temp2,[],2);
        tempseq=[1:1:L1]';
        centeridx=find([tempidx-tempseq]==0);
        LC=length(centeridx);
        centre0=zeros(LC,W);
        centrelabel0=zeros(LC,1);
        for jj=1:1:LC
            seq=find(temp1(centeridx(jj),:)==1);
            centre0(jj,:)=data1(centeridx(jj),:);
            tempPI(seq)=jj;
        end
        [~,tempPI]=min(dist1(:,centeridx),[],2);
        PartIdx0(tempseq4)=tempPI+LC0;
        LC0=LC0+LC;
        indi0=zeros(LC,1);
        for jj=1:1:LC
            seq=find(tempPI==jj);
            templ=unique(label1(seq));
            indi0(jj)=length(templ)-1;
            if indi0(jj)==0
                centrelabel0(jj)=unique(templ);
                tempseq2=[tempseq2;tempseq4(seq)];
            else
                centrelabel0(jj)=NaN;
            end
        end
        centre{count}=[centre{count};centre0];
        links{count-1}=[links{count-1};ones(LC,1)*ii];
        centrelabel{count}=[centrelabel{count};centrelabel0];
        indi1=[indi1;indi0];
    end
    indi=indi1;
    PartIdx=PartIdx0;
    dist0(tempseq2,:)=[];
    dist0(:,tempseq2)=[];
    tradata(tempseq2,:)=[];
    tralabel(tempseq2)=[];
    PartIdx(tempseq2)=[];
    L=length(tralabel);
    if sum(isnan(centrelabel{count}))==length(centrelabel{count}) & length(centrelabel{count})==length(centrelabel{count-1}) & count>5
        break
    end
end
systemparameter.centrelabels=centrelabel;
systemparameter.centres=centre;
systemparameter.centrelinks=links;
%%
traintime=toc;
tesdata=tesdata(:,seqts);
LH=length(centrelabel);
[L,W]=size(tesdata);
Estlabel=zeros(L,1);
centres=[];
centrelabels=[];
delta=[];
for jj=1:1:LH
    seq=find(isnan(centrelabel{jj})==0);
    centres=[centres;centre{jj}(seq,:)];
    centrelabels=[centrelabels;centrelabel{jj}(seq,:)];
    delta=[delta;ones(length(seq),1)*averdist(jj)];
end
centres1=centres./repmat(TS,length(centrelabels),1);
for ii=1:1:L
    dist1=pdist2(centres1,tesdata(ii,:)./TS,'euclidean');
    [~,idx]=min(dist1);
    Estlabel(ii)=centrelabels(idx);
end
end
