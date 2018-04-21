--erl, x5....
--CS360 Project 1, Final Program
--27 March 2003

WITH Ada.Text_IO, Ada.Float_Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Elementary_Functions;
USE Ada.Text_IO, Ada.Float_Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Elementary_Functions;

PROCEDURE Proj1 IS

   MaxLength : CONSTANT Integer := 25;    --maximum number of data sets
   SUBTYPE Choice IS Integer RANGE 1..9;  --range of menu choices
   SUBTYPE DataPoint IS FLOAT RANGE -100.0..100.0;  --range of data points
   TYPE DataArray IS Array (1..MaxLength) OF DataPoint; --array type for data points
   XData, YData : DataArray := (OTHERS => 0.0); --data point holding array
   Length: Integer := 0;                       --number of data points entered
   MenuChoice : Choice := 1;                   --menu choice entered by user

   --Sub to get the data input from the user
   PROCEDURE GetInput(XData, YData : IN OUT DataArray;
                      Length : IN OUT Integer) IS
      Another : Character := 'y';
   BEGIN
      WHILE Another = 'y' LOOP
         BEGIN
            Length := Length + 1;
            New_Line;
            Put("Enter the next X Value: ");
            Get(item => XData(Length));
            Put("Enter the next Y Value: ");
            Get(item => YData(Length));
            New_Line;
            Put("Enter another observation (y/n)? ");
            Get(Another);
            EXCEPTION
               WHEN Constraint_Error | Data_Error =>
                  New_Line;
                  Put_Line("Your data set was no good.");
                  Length := Length - 1;
         END;
      END LOOP;
   END GetInput;

   --sub to display the data sets entered by the user
   PROCEDURE DisplayRecent(XData, YData : IN DataArray;
                           Length: IN Integer) IS
      Counter : Integer := 0;
   BEGIN
      Put_Line("Your current data set, [X, Y], is:");
      FOR Counter IN 1..Length LOOP
         Put(XData(Counter),2,5,0);
         Put(", ");
         Put(YData(Counter),2,5,0);
         New_Line;
      END LOOP;
   END DisplayRecent;

   --sub to display the mean value of the range
   PROCEDURE DisplayMean(YData : IN DataArray;
                         Length: IN Integer) IS
      Counter : Integer := 1;
      YAve : Float := 0.0;
   BEGIN
      FOR Counter IN 1..Length LOOP
         YAve := YAve + YData(Counter);
      END LOOP;
      YAve := YAve / Float(Length);
      Put("The mean of the range is: ");
      Put(YAve,2,5,0);
   END DisplayMean;

   --sub to display the standard deviation of the range
   PROCEDURE DisplayStdDev(YData : IN DataArray;
                           Length: IN Integer) IS
      Counter : Integer := 0;
      Term1 : Float := 0.0;
      Term2 : Float := 0.0;
      StdDev : Float := 0.0;
   BEGIN
      FOR Counter IN 1..Length LOOP
         Term1 := Term1 + (YData(Counter)**2);
         Term2 := Term2 + YData(Counter);
      END LOOP;
      Term2 := (Term2**2) / Float(Length);
      StdDev := ((Term1-Term2) / (Float(Length)-1.0))**(1.0/2.0);
      Put("The standard deviation is: ");
      Put(StdDev,2,5,0);
   END DisplayStdDev;

   --sub to display pearson's correlation coefficient
   PROCEDURE DisplayCorrelation(XData, YData : IN DataArray;
                                Length: IN Integer) IS
      XAve : Float := 0.0;
      YAve : Float := 0.0;
      Sxx : Float := 0.0;
      Syy : Float := 0.0;
      Sxy : Float := 0.0;
      r : Float := 0.0;
      Counter : Integer := 0;
   BEGIN
      FOR Counter IN 1..Length LOOP
         YAve := YAve + YData(Counter);
         XAve := XAve + XData(Counter);
      END LOOP;
      YAve := YAve / Float(Length);
      XAve := XAve / Float(Length);
      FOR Counter IN 1..Length LOOP
         Sxx := Sxx+((XData(Counter)-XAve)**2);
         Syy := Syy+((YData(Counter)-YAve)**2);
         Sxy := Sxy+((XData(Counter)-XAve)*(YData(Counter)-YAve));
      END LOOP;
      r := Sxy/((Sxx*Syy)**(1.0/2.0));
      Put("Pearson's coefficient of correlation is: ");
      Put(r,2,5,0);
   END DisplayCorrelation;

   --sub to display histogram
   PROCEDURE DisplayHistogram(YData : IN DataArray;
                              Length: IN Integer) IS
      YMax : Float := -100.0;
      YMin : Float := 100.0;
      ArrayCounter : Integer := 0;
      IntervalCounter : Integer := 0;
      Interval : Float := 0.0;
      Stars : Integer := 0; --to fix when YMax exactly ='s End of last bin
   BEGIN
      FOR ArrayCounter IN 1..Length LOOP
         IF YMax < YData(ArrayCounter) THEN
            YMax := YData(ArrayCounter);
         END IF;
         IF YMin > YData(ArrayCounter) THEN
            YMin := YData(ArrayCounter);
         END IF;
      END LOOP;
      Interval := (YMax - YMin) / 10.0;
      FOR IntervalCounter IN 0..9 LOOP --display histogram intervals
         New_Line;
         Put((YMin + (Interval * Float(IntervalCounter))),2,2,0);
         Put(": ");
         FOR ArrayCounter IN 1..Length LOOP --find where data fits in histogram
            IF ((YData(ArrayCounter) >= (YMin + (Float(IntervalCounter) * Interval))) AND
                (YData(ArrayCounter) < (YMin + (Float(IntervalCounter+1) * Interval)))) THEN
               Put ("*");
               Stars := Stars + 1;
            END IF;
         END LOOP;
      END LOOP;
      IF Stars < Length THEN
         Put("*");
      END IF;
   END DisplayHistogram;

   --make sure that the user entered enough data
   FUNCTION CheckData(Needed: IN Integer;
                      Length: IN Integer) Return Boolean IS
   BEGIN
      IF Length < Needed THEN
         Put_Line("You need to enter more data before you can perform this function.");
         New_Line(2);
         Return False;
      END IF;
      Return True;
   END CheckData;

BEGIN --main program body
   Put("This program calculates descriptive statistics for data sets that you input");

   WHILE (MenuChoice /= 9) LOOP --display menu and have user choose option
      New_Line(2);
      Put_Line("Make your choice from the menu below:");
      New_Line;
      Put_Line("1. Accept input of a new data set.");
      Put_Line("2. Display the most recently input data set.");
      Put_Line("3. Display only the mean.");
      Put_Line("4. Display only the standard deviation.");
      Put_Line("5. Display only Pearson's coefficient of correlation.");
      Put_Line("6. Display the number of observations.");
      Put_Line("7. Display all descriptive statistics.");
      Put_Line("8. Display a ten-bin histogram.");
      Put_Line("9. Exit the program.");
      LOOP
         BEGIN
            New_Line;
            Put("Enter your choice: ");
            Get(MenuChoice);
            EXIT;
            EXCEPTION
               WHEN Constraint_Error | Data_Error =>
                  Skip_Line;
                  Put_Line("That menu choice was no good.");
         END;
      END LOOP;
      New_Line;

      CASE MenuChoice IS --call subs based on user's choice
         WHEN 1 =>
            IF Length = MaxLength THEN
               Put_Line("You have entered the maximum amount of data.");
            ELSE
               GetInput(XData,YData,Length);
            END IF;
         WHEN 2 =>
            IF CheckData(2,Length)=True THEN
               DisplayRecent(XData,YData,Length);
            END IF;
         WHEN 3 =>
            IF CheckData(2,Length)=True THEN
               DisplayMean(YData,Length);
            END IF;
         WHEN 4 =>
            IF CheckData(2,Length)=True THEN
               DisplayStdDev(YData,Length);
            END IF;
         WHEN 5 =>
            IF CheckData(2,Length)=True THEN
               DisplayCorrelation(XData,YData,Length);
            END IF;
         WHEN 6 =>
            Put("The number of observations is: ");
            Put(Length,2);
         WHEN 7 =>
            IF CheckData(2,Length)=True THEN
               DisplayMean(YData,Length); New_Line;
               DisplayStdDev(YData,Length); New_Line;
               DisplayCorrelation(XData,YData,Length);
            END IF;
         WHEN 8 =>
            IF CheckData(2,Length)=True THEN
               DisplayHistogram(YData,Length);
            END IF;
         WHEN 9 =>
            EXIT;
      END CASE;
   END LOOP;
END Proj1;
