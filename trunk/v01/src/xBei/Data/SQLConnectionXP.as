package xBei.Data{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class SQLConnectionXP extends SQLConnection{
		public function SQLConnectionXP()	{
			super();
		}
		
		/**
		 * 创建一个SQLStatement
		 * @return 
		 */
		public function CreateCommand(sql:String = null, parameters:Object = null):SQLStatement{
			var cmd:SQLStatement = new SQLStatement();
			cmd.sqlConnection = this;
			if(sql != null){
				cmd.text = sql;
				if(parameters != null){
					for(var k:* in parameters){
						cmd.parameters[k] = parameters[k];
					}
				}
			}
			return cmd;
		}
		/**
		 * 执行sql
		 * @param sql
		 * @param parameters
		 * @return 
		 */
		public function ExecuteSql(sql:String, parameters:Object = null):Array{
			var cmd:SQLStatement = new SQLStatement();
			cmd.sqlConnection = this;
			cmd.text = sql;
			if(parameters != null){
				for(var k:* in parameters){
					cmd.parameters[k] = parameters[k];
				}
			}
			try{
				cmd.execute();
				return cmd.getResult().data;
			}catch(ex:Error){
				return [];
			}
			return [];
		}
		
		/**
		 * 插入一条记录
		 * @param sql
		 * @param parameters
		 * @return 
		 */
		public function Insert(sql:String, parameters:Object):Number{
			var cmd:SQLStatement = new SQLStatement();
			cmd.sqlConnection = this;
			cmd.text = sql;
			for(var k:* in parameters){
				cmd.parameters[k] = parameters[k];
			}
			cmd.execute();
			var result:SQLResult = cmd.getResult();
			return result.lastInsertRowID;
		}
	}
}