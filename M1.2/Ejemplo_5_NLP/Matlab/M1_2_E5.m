clc 
clear all
close all
% Christian Ardila
% To define global variales
global Dgt Ng Nt BSS_disp
Delta=0;

%% Define load curve  source data
%  Work with load curve introduced in the code Aft=1
%  Work with load curve and SFV from .txt file Aft=2
    Aft_1=2;
    
%% Define SFV source data
%  Work with load curve introduced in the code Aft=1
%  Work with load curve and SFV from .txt file Aft=2
    Aft_2=2;    
%% Define WG source data
%  Work with load curve introduced in the code Aft=1
%  Work with load curve and SFV from .txt file Aft=2
    Aft_3=2;  
%% Define Thermal Generators source data
%  Work with load curve introduced in the code Aft=1
%  Work with load curve and SFV from .txt file Aft=2
    Aft_4=1;     
    
%% Define if compute dispatch with BSS

 % 1=> Compute dispatch with BSS
 % 0=> Compute dispatch without BSS
 
 BSS_disp=0;    
%% Define if compute dispatch with wind generation 

%  1=> Compute dispatch with wind generation
 % 0=> Compute dispatch without wind generation
 
 WG_disp=0;

 %% Define if compute dispatch with SFV generation 

%  1=> Compute dispatch with SFV generation
 % 0=> Compute dispatch without SFV generation
 
  SFV_disp=1;
  
%% Battery Data
  % Eficiencia de carga
     nc=0.95;
   % Eficiencia de descarga
      nd=0.92; 
   
  % Capacidad de la bateria MWh
      C=300;
  % Bmin
     Bmin=0.1;
  % Bmax
     Bmax=0.9; 
   
   % C-rate descarga
     Crate_d=0.4;
   
  % C-rate carga
     Crate_c=0.3;
   
   % SOCf
     Socf=100;
   
   % Soci
     Soci=100;
    
   % Variables of baterry
     vob=3;
   
%% Time of analysis
  Th=72;

%% Thermal Generators Data


Dgt=[ 
    
%    a       b      c       Pgmin   Pgmax    Rup     Rdown
   0.14     44      0       30      300     45       45
   0.13     43.7    0       25      390     35       45  
   0.14     45.5    0       35      390     35       35
   0.12     34.1    0       25      360     55       45
   0.16     35.1    0       25      360     35       55
   
   ];


%% Load Data

 % Indicate type of data
   % 1=> p.u. data
   % 2=> MW   data
   
    type_load=1;

% Peak load in MW
   Dmax=1500;

% Load Curve in p.u.

   lcurve= [
    
    0.965
    0.983
    0.999
    0.991
    0.921
    0.9030
    0.947
    0.95
    0.96
    0.91
    
    
    ];

%% Renewable Generation
  % SFV Generation
    % Indicate type of data
     % 1=> p.u. data
     % 2=> MW   data
       type_sfv=1;
   % Pmáx SFV
     Psfv=500;
    
    sfvg=[
        0.7240
        0.8527
        0.9598
        1
        0.9228
        0.8733
        0.7250
        0.68
        0.58
        0.5
        ];
    
    
   % Wind generation
   
   % Indicate type of data
    % 1=> p.u. data
    % 2=> MW   data
      type_wg=2;
     % Pmáx WG 
      Pwg=500;
      wg=[
        200
        100
        50
        50
        100
        300
        400
        500
        400
        300
        ];
    
    
  
%%  Calculations

  % Load curve, wind and solar generation  assignment  
      if Aft_1==2
           
        fileID = fopen('load_curve.txt','r');
        
        formatSpec = '%f';
        lcurve = fscanf(fileID,formatSpec);
        lcurve=lcurve(1:Th,1);
        
      end
      
      if Aft_2==2
           
       
        fileID = fopen('sun_irradiance.txt','r');
        formatSpec = '%f';
        sfvg= fscanf(fileID,formatSpec);
        sfvg=sfvg(1:Th,1);
      end
      
      % if Aft_3==2
      % 
      %   fileID = fopen('windgen_data.txt','r');
      %   formatSpec = '%f';
      %   wg = fscanf(fileID,formatSpec);
      % end
      % 
      if Aft_4==2
       m='gen_data.txt';
       fileID = fopen(m,'r');
       formatSpec = '%f';
       Dgt= fscanf(fileID,formatSpec,[7,5]);
       Dgt= Dgt';
      end
      

    % Unit conversion
    
   if type_load==1
       lcurve=lcurve*Dmax;
   end
   if type_sfv==1
       sfvg=sfvg*Psfv;
   end
    if type_wg==1
       wg=wg*Pwg;
   end


 % Number of thermal generators
   Ng=size(Dgt,1);
   

 

% Number of load periods
   Nt=size(lcurve,1);

 
 if BSS_disp==1
     
     Aeq_bat1=zeros(Nt+1,3*Nt);

     vc1=1;

         for j=1:size(lcurve,1)
             if  j==1
                 Aeq_bat1(1,1)=1/nd;
                 Aeq_bat1(1,2)=-nc;
                 Aeq_bat1(1,3)=1;

                 Aeq_bat1(1,vob*Nt)=-1;


             else
               Aeq_bat1(j,3*vc1)=-1;
               Aeq_bat1(j,3*vc1+1)=1/nd;
               Aeq_bat1(j,3*vc1+2)=-nc;
               Aeq_bat1(j,3*vc1+3)=1;
               vc1=vc1+1;

             end

         end
         % Restricción de SOCf
         Aeq_bat1(j+1,vob*Nt)=1;

         beq_bat1=zeros(Nt+1,1);
         beq_bat1(Nt+1,1)=Socf;

        % beq_bat1(1,1)=Soci;
         beq_bat1(1,1)=0;


          lb_bat=zeros(1,3*Nt); 
          ub_bat=zeros(1,3*Nt); 
          vc1=1;
         for j=1:size(lcurve,1)
             if j==1
              lb_bat(1,1:3*vc1)=[0 0 C*Bmin];   
              ub_bat(1,1:3*vc1)=[C*Crate_d C*Crate_c  C*Bmax];  
             else
              lb_bat(1,3*(vc1-1)+1:3*vc1)=[0 0 C*Bmin];
              ub_bat(1,3*(vc1-1)+1:3*vc1)=[C*Crate_d C*Crate_c  C*Bmax];
             end
             vc1=vc1+1;
         end

     Aeq_bat2=zeros(Nt,Nt*vob);
     sr=0;
        for i=1:size(Aeq_bat2,1)
            Aeq_bat2(i,sr*vob+1)=1;
            Aeq_bat2(i,sr*vob+2)=-1;
            Aeq_bat2(i,sr*vob+3)=0;

            sr=sr+1;
        end
        
 end
 
             
     


% Balance of power constraint only with thermal generators 

    Aeq1=zeros(Nt,Nt*Ng);
    sr=0;
    for i=1:size(Aeq1,1)
        Aeq1(i,sr*Ng+1:Ng*i)=1;

        sr=sr+1;
    end
    beq1=lcurve;
    if SFV_disp==1
      beq1=beq1-sfvg;
    end
    if WG_disp==1
      beq1=beq1-wg;
    end
    

% Upper and lower limits of thermal generators
 cv=1;
for i=1:size(lcurve,1)
    
     for j=1: size(Dgt,1)
         lb1(cv)=Dgt(j,4);
         ub1(cv)=Dgt(j,5);
         cv=cv+1;
     end
    
end

% Thermal generators ramp constraint
    res1=zeros(size(Dgt,1)*(size(lcurve,1)-1),size(Dgt,1)*size(lcurve,1));
     vc3=1;
    for i=1:size(Dgt,1)
        vc1=0;
        vc2=1;

        for j=1:size(lcurve,1)-1
            res1(vc3,Ng*vc1+i)=-1;
            res1(vc3,Ng*vc2+i)=1;
            vc1=vc1+1;
            vc2=vc2+1;
            vc3=vc3+1;
        end
    end

    A=[res1;-res1];

    vc3=1;
    for i=1:size(Dgt,1)
        for j=1:size(lcurve,1)-1
            res1_b1(vc3,1)=Dgt(i,6)+Delta;
            res1_b2(vc3,1)=Dgt(i,7)+Delta;
            vc3=vc3+1;
        end
    end

    b=[res1_b1;res1_b2];

if BSS_disp==1
    
     lb_tot=[lb1,lb_bat];
     ub_tot=[ub1,ub_bat];
     Aeq_tot=[Aeq1,Aeq_bat2;zeros(Nt+1,Nt*Ng),Aeq_bat1];
     beq_tot=[beq1;beq_bat1];
     A_tot=[A,zeros(Ng*(Nt-1)*2,vob*Nt)];
     x0_tot=lb_tot;
else
     lb_tot=lb1;
     ub_tot=ub1;
     Aeq_tot=Aeq1;
     beq_tot=beq1;
     A_tot=A;
     x0_tot=lb1;
end


 options = optimoptions("fmincon",...
    "Algorithm","interior-point",...
     "SubproblemAlgorithm","cg",'Maxiterations',2000,'MaxFunEvals',2600000,'Display','Iter');


[x,fval,exitflag,output,lambda] = fmincon(@calcOpex,x0_tot,A_tot,b,Aeq_tot,beq_tot,lb_tot,ub_tot,[],options);

comp2=[b,A_tot*x'];

% Graph power of each generator
datosgen=disp_graph(x,lcurve,sfvg);

% Graph SOC, Pd y Pc of battery

if  BSS_disp==1
    datosbat=disp_bat_graph(x,vob);
end

% Grpah total power of thermal generators, load, solar, wind and battery

if BSS_disp==1
   totalg(datosgen,lcurve,sfvg,wg,datosbat);
else
    totalg(datosgen,lcurve,sfvg,wg);
end



%% Obtain marginal prices

marg_p=lambda.eqlin(1:Th,1)*-1;

figure(get(gcf, 'Number')+1)

plot(1:Nt,marg_p','m','linewidth',1.5),grid on
 ylabel('Eur/MWh', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
      xlim([0 Nt+1])

%% Solar incomes

sol_incg=dot(sfvg,marg_p');

%% Load pay

load_p=dot(lcurve,marg_p');

if BSS_disp==1
    %% Batterry incomes
    bat_inc=dot(datosbat(1,:),marg_p');
    %% Batterry costs
    bat_cost=dot(datosbat(2,:),marg_p');

    Profit_bat=bat_inc-bat_cost;
end
%% Compute OPEX and income of each generator
[rev_opexg,rev_incg] = calc_incg(datosgen,marg_p);

Total_Opexg=sum(rev_opexg);
Total_Incg=sum(rev_incg);
Profitg=Total_Incg-Total_Opexg;

%% Energy Balance

TotalWh_tg=sum(datosgen(:))/1000;
TotalWh_sfvg=sum(sfvg(:))/1000;
TotalWh_load=sum(lcurve(:))/1000;

 if BSS_disp==1
     TotalWh_des=sum(datosbat(1,:))/1000;
     TotalWh_char=sum(datosbat(2,:))/1000;
     
     Wh_bal=TotalWh_tg+ TotalWh_des+TotalWh_sfvg-TotalWh_char-TotalWh_load;
 else
     Wh_bal=TotalWh_tg+TotalWh_sfvg-TotalWh_load;
     
 end
 
%  opexc=0;
%  for i=1:Nt
%      opexc=opexc+datosbat(2,i)*Dgt(4,1)^2+datosbat(2,i)*Dgt(4,2);
%  end
        
function [rev_opexg,rev_incg] = calc_incg(datosgen,marg_p)

 global Dgt
 
  rev_opexg=zeros(size(Dgt,1),1);
  rev_incg=zeros(size(Dgt,1),1);
  
  for i=1:size(datosgen,2)
      for j=1:size(Dgt,1)
          rev_opexg(j,1)=rev_opexg(j,1)+Dgt(j,1)*datosgen(j,i)^2+Dgt(j,2)*datosgen(j,i)+Dgt(j,3);
      end
  end
  
  for i=1:size(datosgen,1)
      rev_incg(i,1)=dot(datosgen(i,:),marg_p');
  end
      
      


end


function totalg(datosgen,load,solar,wg,datosbat,varargin)
  fig_num = get(gcf, 'Number');
  
  global Nt BSS_disp
  
  t=1:1:Nt;
  figure(fig_num+1)
  plot(t,sum(datosgen,1),'linewidth',1.5),grid on
  hold on
 
  plot(t,solar,'linewidth',1.5),grid on
  hold on
  
  if BSS_disp ==1
     plot(t,datosbat(1,:),'linewidth',1.5),grid on
     hold on
     plot(t,datosbat(2,:),'linewidth',1.5),grid on
     hold on
  end
   plot(t,load,'linewidth',1.5),grid on
  hold on
  
  if BSS_disp ==1
      legend('Pg térmica','Pg solar','Pd batería','Pc batería',' Load')
  else
      legend('Pg térmica','Pg solar',' Load')
  end
    ylabel('P [MW]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
  
end


function Opex=calcOpex(x)

global Nt Ng Dgt

    Opex=0;
   % Ng=5;
    %Nt=168;
    cv=1;
       for i=1:Nt
           for j=1:Ng
               %%%%VERIFICAR
               Opex=Opex+Dgt(j,1).*x(cv)^2+Dgt(j,2)*x(cv)+Dgt(j,1);
               cv=cv+1;
           end
       end

       %disp('entró')
             
  
end


function datosgen = disp_graph(sol,lcurve,sfvg)
  
 
 global Ng Nt
        k=1;
        p=1;
        for i=1:Nt
            for j=1:Ng
                datosgen(j,k)=sol(1,p);
                p=p+1;
            end
            k=k+1;
        end
 t= 1:1:Nt;
  for i=1:size(datosgen,1) 
      figure(1)
      plot(t,datosgen(i,:),'linewidth',1.5), grid on
       legends{i} = sprintf('G%d', i);
      hold on
  end
  legend(legends)
  ylabel('P [MW]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
    xlim([0 Nt+1])
  
  fig_num = get(gcf, 'Number');
  figure (fig_num+1)
   plot(t,lcurve,'linewidth',1.5), grid on
   ylabel('P [MW]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
   xlim([0 Nt+1])

   figure (fig_num+2)
   bar(datosgen','stacked')
   legend(legends)   
    ylabel('P [MW]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
   figure (fig_num+3)
   plot(t,sfvg,'linewidth',1.5),grid on
    ylabel('P [MW]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
      xlim([0 Nt+1])

end

function datosbat=disp_bat_graph(sol,vob)

 fig_num = get(gcf, 'Number');
 global Ng Nt
        k=Nt*Ng+1;
        p=0;
        for i=1:Nt
           datosbat(1,i)=sol(1,k+3*p);
           datosbat(2,i)=sol(1,k+3*p+1);
           datosbat(3,i)=sol(1,k+3*p+2);
           p=p+1;
       end
            
        
 t= 1:1:Nt;
 
 figure(fig_num+1)
 
 bar(datosbat(1,:))
 hold on
 bar(datosbat(2,:))
 legend('Pd','Pc')
 ylabel('P[MW]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
  
 figure(fig_num+2)
 bar(datosbat(3,:))
 legend('SOC')
 
  ylabel('[MWh]', 'Fontsize',14, 'Fontweight','bold'),xlabel('Hour','Fontsize',14,'Fontweight','bold')
 
 end

