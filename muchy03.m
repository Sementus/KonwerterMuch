clc

%% Deklaracja zmiennych

monitor = Monitor15;
liczba_wierszy = size(monitor,1);
liczba_kolumn = size(monitor,2);

kol_czas = VarName3;
kol_swiatlo = 10;
pierwsza_mucha = 11;%27;        %nr kolumny
ostatnia_mucha = 26;%42;        %nr kolumny

pierwsza_godzina = datetime('2:00:00');
ostatnia_godzina = datetime('1:55:00');
dwudziesta_godzina = datetime('20:00:00');

dl_binow = 5;      %[min]
liczba_pomiarow = 24*60/dl_binow;
liczba_pom_30 = liczba_pomiarow/6;
liczba_much = ostatnia_mucha-pierwsza_mucha+1;

%% Obliczanie badanego zakresu

czas_start = 0;
czas_koniec_LD_20 = 0;
czas_koniec_DD = 0;

%Pierwszy wiersz (pierwsza 2:00:00)
for i=1:1:liczba_wierszy
    if czas_start == 0
        while kol_czas(i,1) == pierwsza_godzina
            czas_start = i;
            break;
        end
    end
end

%Preostatni wiersz (ostatnia 1:55:00)
for i=1:1:liczba_wierszy
    if czas_koniec_DD == 0
        while kol_czas(liczba_wierszy-i,1) == ostatnia_godzina
        	czas_koniec_DD = liczba_wierszy-i;
        	break;
        end
    end
end

%Ostatnia jedynka (20:00:00)
for i=1:1:liczba_wierszy
    if czas_koniec_LD_20 == 0
        while kol_czas(liczba_wierszy-i,1) == dwudziesta_godzina
            if monitor(liczba_wierszy-i,kol_swiatlo) == 1;
                czas_koniec_LD_20 = liczba_wierszy-i;
            end
        	break;
        end
    end
end

%Ostatni wiersz LD
czas_koniec_LD = czas_koniec_LD_20+6*(60/dl_binow)-1;

%Liczba faz/dni
czas_liczba_LD = (czas_koniec_LD-czas_start+1)/liczba_pomiarow;
czas_liczba_DD = (czas_koniec_DD-czas_koniec_LD)/liczba_pomiarow;
czas_liczba_dni = czas_liczba_LD+czas_liczba_DD;

%% Konwersja na tablice dla binow 30 min

for i_muchy=pierwsza_mucha:1:ostatnia_mucha
    for i_doby=1:1:czas_liczba_dni
        for i_pomiary=1:1:liczba_pom_30
            
            %Tablica do testow
            test_akt_30(liczba_pom_30*(i_doby-1)+i_pomiary,1) = 6*(liczba_pom_30*(i_doby-1)+(i_pomiary-1))+czas_start;
            test_akt_30(liczba_pom_30*(i_doby-1)+i_pomiary,2) = liczba_pom_30*(i_doby-1)+i_pomiary;

            %Tablica aktywnosci w 30 min
            akt_30(liczba_pom_30*(i_doby-1)+i_pomiary,i_muchy-pierwsza_mucha+1) = sum(monitor(6*(liczba_pom_30*(i_doby-1)+(i_pomiary-1))+(czas_start-5):1:6*(liczba_pom_30*(i_doby-1)+(i_pomiary-1))+czas_start,i_muchy));
            
            %Swiatlo w 30 min
            swiatlo_30(liczba_pom_30*(i_doby-1)+i_pomiary,1) = monitor(6*(liczba_pom_30*(i_doby-1)+(i_pomiary-1))+czas_start,kol_swiatlo);
            
            %Godziny dla danych aktywnosci w 30 min
            czas_30(liczba_pom_30*(i_doby-1)+i_pomiary,1) = kol_czas(6*(liczba_pom_30*(i_doby-1)+(i_pomiary-1))+czas_start,1);
            
        end
    end
end

%sprawdzenie testowej tablicy
%for i_test=1:1:size(test_akt_30,1)
%    test_akt_30(liczba_pom_30*(i_doby-1)+i_pomiary,3) = czas_start-6*(i_test-1);
%end
%test_srednia = mean(test_akt_30)

%% Tworzenie udawanego dnia LD dla KAZDEJ muchy

for i_muchy=1:1:liczba_much
    for i_pomiary=1:1:liczba_pom_30
            
            % Obliczanie udawanego dnia z usrednionych wartosci
            dzien_sr_LD(i_pomiary,i_muchy) = mean(akt_30(i_pomiary:liczba_pom_30:(i_pomiary+liczba_pom_30*(czas_liczba_LD-1)),i_muchy));
            
            % Obliczanie odchylenia standardowego do udawanego dnia
            dzien_odch_LD(i_pomiary,i_muchy) = std(akt_30(i_pomiary:liczba_pom_30:(i_pomiary+liczba_pom_30*(czas_liczba_LD-1)),i_muchy));

            %Kolmna swiatla dla jednego dnia
            dzien_swiatlo_LD(i_pomiary,1) = swiatlo_30(i_pomiary,1);
            
    end
end
%% Tworzenie udawanego dnia DD dla KAZDEJ muchy

for i_muchy=1:1:liczba_much
    for i_pomiary=1:1:liczba_pom_30
           
            % Obliczanie udawanego dnia z usrednionych wartosci
            dzien_sr_DD(i_pomiary,i_muchy) = mean(akt_30((i_pomiary+liczba_pom_30*czas_liczba_LD):liczba_pom_30:(i_pomiary+liczba_pom_30*(czas_liczba_dni-1)),i_muchy));
            
            % Obliczanie odchylenia standardowego do udawanego dnia
            dzien_odch_DD(i_pomiary,i_muchy) = std(akt_30(czas_liczba_DD*i_pomiary:liczba_pom_30:((czas_liczba_LD+czas_liczba_DD)*i_pomiary),i_muchy));

            %Kolmna swiatla dla jednego dnia
            dzien_swiatlo_DD(i_pomiary,1) = swiatlo_30(i_pomiary,1);
            
    end
end

%% Tworzenie udawanego dnia dla WSZYSTKICH much

for i_pomiary=1:1:liczba_pom_30
    
    % Obliczanie udawanego dnia z usrednionych wartosci
    dzien_all_sr_LD(i_pomiary,1) = mean(dzien_sr_LD(i_pomiary,1:1:liczba_much));
    dzien_all_sr_DD(i_pomiary,1) = mean(dzien_sr_DD(i_pomiary,1:1:liczba_much));
            
    % Obliczanie odchylenia standardowego do udawanego dnia
    dzien_all_odch_LD(i_pomiary,1) = mean(dzien_odch_LD(i_pomiary,1:1:liczba_much));
    dzien_all_odch_DD(i_pomiary,1) = mean(dzien_odch_DD(i_pomiary,1:1:liczba_much));

end

%% Wykres LD

subplot(2,1,1);
hold on;

for i_godzina=1:1:liczba_pom_30
    
    if dzien_swiatlo_LD(i_godzina,1) == 1    	%warunek na znacznik fazy (L or D)

        bar(i_godzina, dzien_all_sr_LD(i_godzina,1), 'white');         	%bialy slupek

    elseif dzien_swiatlo_LD(i_godzina,1) == 0    %warunek na znacznik nie rowna sie 1 (czyli 0)

        bar(i_godzina, dzien_all_sr_LD(i_godzina,1), 'black');           %czarny slupek

    end							%koniec instrukcji if
end	

hold off;

title('Aktywnosc much przez jeden dzien LD');
legend('Aktywnosc', 1);
ylabel('Aktywnosc');
xlabel('Czas');
set(gca, 'xtick', [1 liczba_pom_30/4+1 2*liczba_pom_30/4+1 3*liczba_pom_30/4+1 liczba_pom_30-1], 'xticklabel', {'2:00:00', '8:00:00', '14:00:00', '20:00:00', '1:00:00'})
xlim([0 liczba_pom_30+1]);

%% wykres DD

subplot(2,1,2);
bar(dzien_all_sr_DD, 'black');           %czarny slupek

title('Aktywnosc much przez jeden dzien DD');
legend('Aktywnosc', 1);
ylabel('Aktywnosc');
xlabel('Czas');
set(gca, 'xtick', [1 liczba_pom_30/4+1 2*liczba_pom_30/4+1 3*liczba_pom_30/4+1 liczba_pom_30-1], 'xticklabel', {'2:00:00', '8:00:00', '14:00:00', '20:00:00', '1:00:00'})
xlim([0 liczba_pom_30+1]);