String cronExp = '0 0 1 * * ?';

System.schedule(
    'Daily Complaint Summary Job',
    cronExp,
    new ComplaintScheduler()
);