using System;
using System.Collections.Generic;
using System.Globalization;

namespace Infrastructure.Utils
{
    public static class HolidayUtility
    {
        private static readonly ChineseLunisolarCalendar _lunarCalendar = new ChineseLunisolarCalendar();

        public static bool IsPublicHoliday(DateTime date)
        {
            // Solar holidays
            if (date.Month == 1 && date.Day == 1) return true;   // New Year
            if (date.Month == 4 && date.Day == 30) return true;  // Victory Day
            if (date.Month == 5 && date.Day == 1) return true;   // Labor Day
            if (date.Month == 9 && date.Day == 2) return true;   // National Day

            // Lunar holidays
            int year = _lunarCalendar.GetYear(date);
            int month = _lunarCalendar.GetMonth(date);
            int day = _lunarCalendar.GetDayOfMonth(date);
            bool isLeapMonth = _lunarCalendar.IsLeapMonth(year, month);

            // Hung Kings Day (10/03 Lunar) - Skip check if it's a leap month (usually only the first month is holiday)
            if (!isLeapMonth)
            {
                // We need to handle the case where GetMonth returns an index including leisure months
                int actualMonth = GetActualLunarMonth(year, month);
                
                // Hung Kings Day (10/3 Lunar)
                if (actualMonth == 3 && day == 10) return true;

                // Tet Holiday (29/12 to 5/1 Lunar)
                // Note: Tet can start from 29/12 if 12th month has only 29 days
                if (actualMonth == 1 && day >= 1 && day <= 5) return true;
                
                // Check for 29/12 or 30/12 Lunar (Tet Eve)
                if (actualMonth == 12 && day >= 29)
                {
                    // More precise: usually Tet starts from 30/12, or 29/12 if month ends there
                    // For simplicity in this app, we treat 30/12 as Eve.
                    if (day == 30) return true;
                    // Check if 29 is the last day of month 12
                    if (day == 29 && _lunarCalendar.GetDaysInMonth(year, month) == 29) return true;
                }
            }

            return false;
        }

        private static int GetActualLunarMonth(int year, int monthIndex)
        {
            int leapMonth = _lunarCalendar.GetLeapMonth(year);
            if (leapMonth == 0 || monthIndex < leapMonth) return monthIndex;
            if (monthIndex == leapMonth) return -(monthIndex - 1); // Negative for leap
            return monthIndex - 1;
        }

        public static bool IsSunday(DateTime date)
        {
            return date.DayOfWeek == DayOfWeek.Sunday;
        }
    }
}
