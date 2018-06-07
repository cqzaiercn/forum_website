<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/commons/global.jsp" %>
<script type="text/javascript">
    var permissonTreeGrid;
    $(function() {
    	permissonTreeGrid = $('#permissonTreeGrid').treegrid({
            url : '${path }/permisson/treeGrid',
            idField : 'id',
            treeField : 'peName',
            parentField :'peParent',
            height:"auto", 
            initialState:"collapsed",
            frozenColumns : [ [ {
                title : '编号',
                field : 'peId',
                width : 40
            } ] ],
            columns : [ [ {
                field : 'peName',
                title : '资源名称',
                width : 150
            },
            {
                field : 'peUrl',
                title : '资源路径',
                width : 200
            }, {
                field : 'peOpenMode',
                title : '打开方式',
                width : 60
            }, {
                field : 'peOpened',
                title : '菜单状态',
                width : 60,
                formatter : function(value, row, index) {
                    if (value == 1) {
                        return '打开';
                    } else {
                        return '关闭';
                    }
                }
            }, {
                field : 'peSeq',
                title : '排序',
                width : 40
            }, {
                field : 'peIcon',
                title : '图标',
                width : 120
            }, {
                field : 'peResourceType',
                title : '资源类型',
                width : 80,
                formatter : function(value, row, index) {
                    switch (value) {
                    case 0:
                        return '菜单';
                    case 1:
                        return '按钮';
                    }
                }
            }, {
                field : 'peParent',
                title : '上级资源ID',
                width : 150,
                hidden : true
            }, {
                field : 'peStatus',
                title : '状态',
                width : 40,
                formatter : function(value, row, index) {
                    switch (value) {
                    case 0:
                        return '正常';
                    case 1:
                        return '停用';
                    }
                }
            } , {
                field : 'action',
                title : '操作',
                width : 130,
                formatter : function(value, row, index) {
                    var str = '';
                        <shiro:hasPermission name="/permisson/edit">
                            str += $.formatString('<a href="javascript:void(0)" class="resource-easyui-linkbutton-edit" data-options="plain:true,iconCls:\'glyphicon-pencil icon-blue\'" onclick="editResourceFun(\'{0}\');" >编辑</a>', row.peId);
                        </shiro:hasPermission>
                        <shiro:hasPermission name="/permisson/delete">
                            str += '&nbsp;&nbsp;|&nbsp;&nbsp;';
                            str += $.formatString('<a href="javascript:void(0)" class="resource-easyui-linkbutton-del" data-options="plain:true,iconCls:\'glyphicon-trash icon-red\'" onclick="deleteResourceFun(\'{0}\');" >删除</a>', row.peId);
                        </shiro:hasPermission>
                    return str;
                }
            }] ],
            onLoadSuccess:function(data){
                $('.resource-easyui-linkbutton-edit').linkbutton({text:'编辑'});
                $('.resource-easyui-linkbutton-del').linkbutton({text:'删除'});
            },
            toolbar : '#resourceToolbar'
        });
    });
    function editResourceFun(id) {
        if (id != undefined) {
        	permissonTreeGrid.treegrid('select', id);
        }
        var node = permissonTreeGrid.treegrid('getSelected');
        if (node) {
            parent.$.modalDialog({
                title : '编辑',
                width : 500,
                height : 350,
                href : '${path}/permisson/editPage?id=' + node.peId,
                buttons : [ {
                    text : '确定',
                    handler : function() {
                        parent.$.modalDialog.openner_treeGrid = resourceTreeGrid;//因为添加成功之后，需要刷新这个treeGrid，所以先预定义好
                        var f = parent.$.modalDialog.handler.find('#resourceEditForm');
                        f.submit();
                    }
                } ]
            });
        }
    }

    function deleteResourceFun(id) {
        if (id != undefined) {
        	permissonTreeGrid.treegrid('select', id);
        }
        var node = resourceTreeGrid.treegrid('getSelected');
        console.info(node);
        if (node) {
            parent.$.messager.confirm('询问', '您是否要删除当前资源？删除当前资源会连同子资源一起删除!', function(b) {
                if (b) {
                    progressLoad();
                    $.post('${path }/permisson/delete', {
                        id : node.peId
                    }, function(result) {
                        if (result.success) {
                            parent.$.messager.alert('提示', result.msg, 'info');
                            resourceTreeGrid.treegrid('reload');
                            parent.layoutWestTree.tree('reload');
                        }
                        progressClose();
                    }, 'JSON');
                }
            });
        }
    }

    function addResourceFun() {
        parent.$.modalDialog({
            title : '添加',
            width : 500,
            height : 350,
            href : '${path }/permisson/addPage',
            buttons : [ {
                text : '添加',
                handler : function() {
                    parent.$.modalDialog.openner_treeGrid = resourceTreeGrid;//因为添加成功之后，需要刷新这个treeGrid，所以先预定义好
                    var f = parent.$.modalDialog.handler.find('#resourceAddForm');
                    f.submit();
                }
            } ]
        });
    }
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
    <div data-options="region:'center',border:false"  style="overflow: hidden;">
        <table id="permissonTreeGrid"></table>
    </div>
</div>
<div id="resourceToolbar" style="display: none;">
    <shiro:hasPermission name="/permisson/add">
        <a onclick="addResourceFun();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'glyphicon-plus icon-green'">添加</a>
    </shiro:hasPermission>
</div>