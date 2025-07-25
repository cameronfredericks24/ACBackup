/* First page margin */
@page:first {
    margin-top: 150px;
}

/* All other pages margin */
@page {
    margin-top: 250px;

@top-center {
content: element(header); 
} 

@bottom-left {
    content: element(footer);
	}
}

div.header {
    position: running(header);
}

div.footer {
    display: block;
    padding: 5px;
    position: running(footer);
}

 

.pagenumber:before {
    content: counter(page);
}

.pagecount:before {
    content: counter(pages);
}