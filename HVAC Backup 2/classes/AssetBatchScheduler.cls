public class AssetBatchScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        AssetBatchProcessor batch = new AssetBatchProcessor();
        Database.executeBatch(batch);
    }
}