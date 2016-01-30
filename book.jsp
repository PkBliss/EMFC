<%@ page   errorPage="error.jsp" language = "java"  import = "java.io.*" session="true" %>
<%@ page   import = "java.sql.DriverManager" %>
<%@ page   import = "java.sql.SQLException" %>
<%@ page   import = "java.sql.Connection" %>
<%@ page   import = "java.sql.Driver" %>
<%@ page   import = "java.sql.Statement" %>
<%@ page   import = "java.lang.String" %>
<%@ page   import = "java.sql.ResultSet" %>
<%@ page   import = "java.text.SimpleDateFormat" %>

<%
try
{

System.out.println("DCATS-INSERT-insert_book.jsp");

String bk_type = request.getParameter("D1");
String bkLang = request.getParameter("D2");
String bk_prod_type = request.getParameter("D3");
String bkOrder = request.getParameter("B1");

String xml=request.getParameter("xml");
String qc=request.getParameter("qc");
String corr=request.getParameter("corr");
String web=request.getParameter("web");
String fqc=request.getParameter("fqc");

SimpleDateFormat dd = new SimpleDateFormat("dd/MM/yyyy");
String qc_date = dd.format(new java.util.Date());
//System.out.println(bkOrder+":"+bk_type+":"+bkLang+":"+bk_prod_type);

Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
//Connection con = DriverManager.getConnection("jdbc:odbc:ELS_DCON_DSN");
Connection con = DriverManager.getConnection("jdbc:odbc:oracle_dsn","dcon","els_dcon");
Statement smt=con.createStatement();
Statement smt1=con.createStatement();

ResultSet rst = null;


//====================check with xml order====================================
String strSQL = ""; String insSql = "";int nx_slno = 0;
String isbn = ""; String bk_title = ""; String bk_edtin = ""; String bk_year = ""; String  jid = ""; String bk_stage = ""; String bk_recd_date = ""; String bk_ch_no = ""; int ch_tot_page =  0; String ch_frm_page = ""; String bk_due_date = ""; String ch_end_page = ""; String str = ""; String str_page_val = ""; String ch_doi = ""; int bokYear = 0; int upd = 0; int tot_upd = 0;

	str = bkOrder;//"//10.10.10.2/Books_Order/"+prj+"/"+isbn+"/"+stage+"/Current_Order/"+prj+"_"+isbn+"_"+stage+".xml";

//System.out.println(str);
BufferedReader input = new BufferedReader(new FileReader(str));
String line = "";
while ((line = input.readLine()) != null) {
	line = line.replace("\t","");
	line = line.replace("  ","");
	line = line.replace(" >",">");
	int len = line.length();
    
	//System.out.println(line);
	//PII

	//To find ISBN
	if (len>=6){
		String ss = line.substring(0,6);
		if(ss.equals("<isbn>")){
			//System.out.println(ss);
			 int indx = line.indexOf("</isbn>");
			 //System.out.println(line+":"+line.substring(6, indx));
			isbn =line.substring(6, indx);
			//System.out.println(isbn);
			}
	}

	//Book Title
	if (len>=12){
		String ss = line.substring(0,12);
		if(ss.equals("<book-title>")){
			 int indx = line.indexOf("</book-title>");
			bk_title =line.substring(12,indx);
			//System.out.println(bk_title);
		}
	}

	//Edition
	if (len>=9){
		String ss = line.substring(0,9);
		if(ss.equals("<edition>")){
			 int indx = line.indexOf("</edition>");
			bk_edtin =line.substring(9,indx);
			//System.out.println(bk_edtin);	
		}
	}

//Stage
	if (len>=7){
		String ss = line.substring(0,7);
		if(ss.equals("<stage>")){
			 int indx = line.indexOf("</stage>");
			bk_stage =line.substring(7,indx);
			//System.out.println(bk_stage);	
		}
	}
	
//Year
if (len>=15){
		String ss = line.substring(0,15);
		if(ss.equals("<reg-year year=")){
			 int indx = line.indexOf("/>");
			bk_year =line.substring(16,indx-1);
			//System.out.println(bk_year);	
			bokYear = Integer.parseInt((bk_year).trim());
		}
	}

//Job Type
if (len>=9){
		String ss = line.substring(0,9);
		if(ss.equals("<jobType>")){
			 int indx = line.indexOf("</jobType>");
			jid =line.substring(9,indx);
			//System.out.println(jid);	
		}
	}

//Received date
if (len>=19){
		String ss = line.substring(0,19);
		if(ss.equals("<received-date day=")){
			 int indx = line.indexOf(" month=");
			 String rec_dat = line.substring(20, 22);
             String rec_mon = line.substring(31, 33);
             String rec_yer = line.substring(41, 45);
             bk_recd_date = rec_dat + "/" + rec_mon + "/" + rec_yer;
			 //System.out.println(bk_recd_date);	
		}
	}
	
//Due date
if (len>=14){
		String ss = line.substring(0,14);
		if(ss.equals("<due-date day=")){
			 int indx = line.indexOf(" month=");
			 String due_dat = line.substring(15, 17);
             String due_mon = line.substring(26, 28);
             String due_yer = line.substring(36, 40);
             bk_due_date = due_dat + "/" + due_mon + "/" + due_yer;
			 //System.out.println(bk_due_date);	
		}
	}

//Chapter Number
if (len>=5){
		String ss = line.substring(0,5);
		if(ss.equals("<cno>")){
			 int indx = line.indexOf("</cno>");
			bk_ch_no = line.substring(5, indx);
			//System.out.println(bk_ch_no);	
		}
	}

if (len>=5){
		String ss = line.substring(0,5);
		if(ss.equals("<pii>")){
			 int indx = line.indexOf("</pii>");
			ch_doi = line.substring(5, indx);
			//System.out.println(ch_doi);	
		}
	}
 
//Total Pages
if (len>=10){
		String ss = line.substring(0,10);
		if(ss.equals("<mss-page>")){
			 int indx = line.indexOf("</mss-page>");
			 str_page_val = line.substring(10, indx);
			 //System.out.println(str_page_val);
			 ch_tot_page = Integer.parseInt((str_page_val).trim());
		}
	}
//Start Pages
if (len>=11)
{
		String ss = line.substring(0,11);
		if(ss.equals("<from-page>")){
			 int indx = line.indexOf("</from-page>");
			 ch_frm_page = line.substring(11, indx);
			 //System.out.println(ch_frm_page);
		}
	}
	
//End Pages
if (len>=9){
		String ss = line.substring(0,9);
		if(ss.equals("<to-page>")){
			 int indx = line.indexOf("</to-page>");
			 ch_end_page = line.substring(9, indx);
			 //System.out.println(ch_end_page);
		}
	}

	//Check all variables having values
	 if(isbn.equals("") || bk_title.equals("") || bk_edtin.equals("") || bk_year.equals("") || jid.equals("") || bk_stage.equals("") || bk_recd_date.equals("") || bk_ch_no.equals("") || ch_tot_page == 0 || ch_frm_page.equals("") || ch_end_page.equals("")){

		 
	 }else{
		 strSQL = "select max(slno) as msl from tracking";
		 rst=smt.executeQuery(strSQL);
		 if(rst.next()){
			 nx_slno = rst.getInt("msl");
		 }
		nx_slno++;
		insSql = "insert into tracking(slno,project,acronym,DOI,iss_year,volume,issue,aid,s_page,e_page,t_page,ft_page,stage,art_type,PROD_TYPE,SPL_TITLE,RECD_DATE,duedate,lang)values("+nx_slno+",'"+jid+"','"+isbn+"','"+ch_doi+"',"+bokYear+",'"+bk_edtin+"','"+bk_edtin+"','"+bk_ch_no+"','"+ch_frm_page+"','"+ch_end_page+"',"+ch_tot_page+",0,'"+bk_stage+"','"+bk_type+"','"+bk_prod_type+"','NIL',to_date('"+bk_recd_date+"','dd/mm/yyyy'),to_date('"+bk_due_date+"','dd/mm/yyyy'),'"+bkLang+"') ";
		upd = smt1.executeUpdate(insSql);
		if(upd>0){
			tot_upd = tot_upd + 1;
		}
		//System.out.println(insSql);
		ch_tot_page = 0;
		nx_slno = 0;
		bk_ch_no = "";
		ch_frm_page = "";
		ch_end_page = "";
	 }

}
/*
System.out.println("project:"+jid);
System.out.println("acronym:"+isbn);
System.out.println("year:"+bokYear);
System.out.println("volume:"+bk_edtin);
System.out.println("issue:"+bk_edtin);

System.out.println("xml:"+xml);
System.out.println("qc:"+qc);
System.out.println("corr:"+corr);
System.out.println("web:"+web);
System.out.println("fqc:"+fqc);
*/
String query="insert into NORMS_ISU_WISE(PROJECT,ACRONYM,ISS_YEAR,VOLUME,ISSUE,XML,QC,CORR,WEB,FQC) values('"+jid+"','"+isbn+"','"+bokYear+"','"+bk_edtin+"','"+bk_edtin+"',"+xml+","+qc+","+corr+","+web+","+fqc+")";
if(tot_upd>=1)
{
	upd = smt1.executeUpdate(query);
}
%>
<html>
<head>
<title>Book Inserting</title>

 <link href="../style/dcats.css" rel="stylesheet" type="text/css"> 
 <script language="javascript">
     window.history.forward(1);
</script> 
<SCRIPT LANGUAGE="JavaScript">
<!--
	function freshFun() {
		 
		document.bookFrm.action="select_book_order.jsp";
		document.bookFrm.submit();
	  }
					
//-->
</SCRIPT>
</head>
<body bgcolor="#BED9FE" class="main">
<form method="POST" name="bookFrm" action="--WEBBOT-SELF--"  target="main">
  
  <p align="center">
<%
	  if(tot_upd>=1){
	  %>
	  <br><br>
	   <CENTER><B><FONT SIZE="4" color="#3366FF"><%=tot_upd%> Chapters inserted Successfully for ISBN <%=isbn%> </FONT></B>
	   <br><br><br>
	  
	  <%
  }else{
		  %>
		  <b><font size="5" color="#FF0000">Error in inserting Book</font></b><br><br>
		  <%
  }
	  %>
<input type="button" name="dd" value="Again" onclick="freshFun()">

</form>
</body>
</html>
<%
	con.close();
	smt.close();
	smt1.close();
    }catch(SQLException se)
     {
  			System.out.println("SQL Exception:"+se.getMessage());
	}catch(ClassNotFoundException cfe){
			System.out.println("Class:"+cfe.getMessage());
    }
%>
